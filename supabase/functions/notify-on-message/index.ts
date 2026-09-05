import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

interface MessageRecord {
  conversation_id: string;
  sender_id: string;
  body: string | null;
  image_path: string | null;
}

interface FirebaseServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

function base64Url(bytes: ArrayBuffer | string): string {
  const binary =
    typeof bytes === "string"
      ? bytes
      : String.fromCharCode(...new Uint8Array(bytes));
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
}

function pemToDer(pem: string): ArrayBuffer {
  const base64 = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replaceAll(/\s/g, "");
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

// FCM v1 braucht ein OAuth2-Access-Token statt des alten Server-Keys. Es gibt
// kein Firebase-Admin-SDK fuer Deno/Edge-Functions, deshalb wird der
// Service-Account-JWT-Bearer-Flow hier direkt mit Web Crypto signiert.
async function getAccessToken(account: FirebaseServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const unsigned = `${base64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }))}.${base64Url(
    JSON.stringify({
      iss: account.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    }),
  )}`;

  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(account.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${base64Url(signature)}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!response.ok) {
    throw new Error(`Google OAuth token exchange failed: ${await response.text()}`);
  }
  const json = (await response.json()) as { access_token: string };
  return json.access_token;
}

/** `true`, wenn FCM den Token als dauerhaft ungueltig meldet (App deinstalliert o.ae.). */
async function sendFcmMessage(
  projectId: string,
  accessToken: string,
  token: string,
  data: Record<string, string>,
): Promise<{ unregistered: boolean }> {
  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ message: { token, data } }),
    },
  );
  if (response.ok) return { unregistered: false };

  const errorBody = (await response.json().catch(() => null)) as {
    error?: { details?: { errorCode?: string }[] };
  } | null;
  const unregistered = errorBody?.error?.details?.some(
    (d) => d.errorCode === "UNREGISTERED",
  ) ?? false;
  if (!unregistered) {
    console.error(`FCM send failed for token ${token}: ${JSON.stringify(errorBody)}`);
  }
  return { unregistered };
}

// Datenbank-Webhook auf `messages INSERT` (Task 6.3), ueber die Supabase-
// Dashboard-UI konfiguriert -- bewusst keine Migration, damit das dortige
// Auth-Secret nie in einer committeten Datei landet. Die Webhook-UI schickt
// den `apikey`-Header selbst mit, siehe docs/DECISIONS.md.
export default {
  fetch: withSupabase({ auth: "secret" }, async (req, ctx) => {
    const payload = (await req.json()) as { record?: MessageRecord };
    const message = payload.record;
    if (!message?.conversation_id || !message.sender_id) {
      return Response.json({ error: "invalid payload" }, { status: 400 });
    }

    const { data: conversation } = await ctx.supabaseAdmin
      .from("conversations")
      .select("buyer_id, seller_id")
      .eq("id", message.conversation_id)
      .single();
    if (!conversation) {
      return Response.json({ error: "conversation not found" }, { status: 404 });
    }

    const recipientId =
      conversation.buyer_id === message.sender_id
        ? conversation.seller_id
        : conversation.buyer_id;

    const { data: tokenRows } = await ctx.supabaseAdmin
      .from("device_tokens")
      .select("token")
      .eq("user_id", recipientId);
    if (!tokenRows || tokenRows.length === 0) {
      return Response.json({ skipped: "no device tokens" });
    }

    const { data: sender } = await ctx.supabaseAdmin
      .from("profiles")
      .select("username, display_name")
      .eq("id", message.sender_id)
      .single();

    const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!serviceAccountJson) {
      throw new Error("FIREBASE_SERVICE_ACCOUNT secret not set");
    }
    const account = JSON.parse(serviceAccountJson) as FirebaseServiceAccount;
    const accessToken = await getAccessToken(account);

    // Data-only-Payload (kein `notification`-Feld): sowohl Vordergrund als
    // auch Hintergrund/beendet laufen so ueber denselben Anzeige-Code-Pfad
    // in push_notification_service.dart, siehe dortiger Kommentar.
    const data = {
      conversationId: message.conversation_id,
      title: sender?.display_name ?? sender?.username ?? "Neue Nachricht",
      body: message.body ?? "Bild",
    };

    const results = await Promise.all(
      tokenRows.map((row) =>
        sendFcmMessage(account.project_id, accessToken, row.token, data).then(
          (result) => ({ token: row.token, ...result }),
        ),
      ),
    );

    const staleTokens = results.filter((r) => r.unregistered).map((r) => r.token);
    if (staleTokens.length > 0) {
      await ctx.supabaseAdmin.from("device_tokens").delete().in("token", staleTokens);
    }

    return Response.json({ sent: results.length - staleTokens.length });
  }),
};

/*
Lokaler Aufruf (Secret-Key aus `supabase secrets list`):

curl -i --location --request POST \
  'http://127.0.0.1:54321/functions/v1/notify-on-message' \
  --header 'apikey: <SUPABASE_SECRET_KEY>' \
  --header 'Content-Type: application/json' \
  --data '{"record":{"conversation_id":"...","sender_id":"...","body":"Hallo","image_path":null}}'
*/
