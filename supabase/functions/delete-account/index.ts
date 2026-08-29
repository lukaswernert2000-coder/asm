// Setup type definitions for built-in Supabase Runtime APIs
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";
import type { SupabaseClient } from "jsr:@supabase/supabase-js@2";

// Pfadkonvention aus supabase/migrations/0006_storage.sql: `<user_id>/...`,
// bei listing-images zusaetzlich `<listing_id>/<uuid>.jpg` darunter. Das
// private chat-images-Bucket ist nach `<conversation_id>` organisiert, nicht
// nach user_id, und wird hier bewusst nicht angefasst (siehe DECISIONS.md).
const STORAGE_BUCKETS = ["avatars", "listing-images"];

// `list()` ist nicht rekursiv; Ordner-Eintraege haben `id: null`
// (Supabase-Storage-Konvention), echte Dateien eine echte id.
async function collectStoragePaths(
  admin: SupabaseClient,
  bucket: string,
  prefix: string,
): Promise<string[]> {
  const { data: entries, error } = await admin.storage.from(bucket).list(prefix);
  if (error || !entries) return [];

  const paths: string[] = [];
  for (const entry of entries) {
    const fullPath = `${prefix}/${entry.name}`;
    if (entry.id === null) {
      paths.push(...(await collectStoragePaths(admin, bucket, fullPath)));
    } else {
      paths.push(fullPath);
    }
  }
  return paths;
}

export default {
  fetch: withSupabase({ auth: "user" }, async (_req, ctx) => {
    const userId = ctx.userClaims!.id;

    for (const bucket of STORAGE_BUCKETS) {
      const paths = await collectStoragePaths(ctx.supabaseAdmin, bucket, userId);
      if (paths.length > 0) {
        await ctx.supabaseAdmin.storage.from(bucket).remove(paths);
      }
    }

    // Cascade (on delete cascade auf profiles.id -> auth.users.id, siehe
    // 0001_profiles.sql) raeumt profiles, listings, favorites, blocks,
    // reports, conversations und messages automatisch mit auf.
    const { error } = await ctx.supabaseAdmin.auth.admin.deleteUser(userId);
    if (error) {
      return Response.json({ error: error.message }, { status: 500 });
    }

    return Response.json({ success: true });
  }),
};

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request with a real user's access token as Bearer token:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/delete-account' \
    --header 'Authorization: Bearer <user-access-token>' \
    --header 'apiKey: <anon-key>'

*/
