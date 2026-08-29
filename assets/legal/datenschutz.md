<!-- ENTWURF – anwaltlich prüfen, bevor diese Seite live geht -->

# Datenschutzerklärung

Stand: [DATUM DER VERÖFFENTLICHUNG]

Diese Erklärung beschreibt, welche personenbezogenen Daten ASM (Airsoft Marketplace,
"wir") verarbeitet, wenn du unsere App oder diese Website nutzt.

## 1. Verantwortlicher

Verantwortlich im Sinne der Datenschutz-Grundverordnung (DSGVO) ist die im
[Impressum](impressum.md) genannte Person bzw. das dort genannte Unternehmen.

## 2. Welche Daten wir verarbeiten

- **Nutzername, E-Mail-Adresse, Passwort (als Hash)** – um dein Konto zu erstellen und
  abzusichern. Rechtsgrundlage: Art. 6 Abs. 1 lit. b DSGVO (Vertrag).
- **Geburtsdatum** – als Altersnachweis für Kategorien mit gesetzlicher 18+-Grenze
  (§ 42a WaffG). Wird **nicht** an andere Nutzer weitergegeben, nur intern zur
  Ja/Nein-Prüfung verwendet. Rechtsgrundlage: Art. 6 Abs. 1 lit. c DSGVO (rechtliche
  Verpflichtung).
- **Postleitzahl (keine GPS-Daten)** – für die Entfernungsangabe im Feed
  ("12 km entfernt"), aufgelöst über einen in der App gebündelten Datensatz, nicht über
  Standortermittlung. Rechtsgrundlage: Art. 6 Abs. 1 lit. b DSGVO.
- **Anzeigename, Profilbild, Bio (optional)** – für dein öffentliches Profil.
  Rechtsgrundlage: Art. 6 Abs. 1 lit. a DSGVO (Einwilligung durch freiwillige Angabe).
- **Inseratsdaten und Fotos** – Kernfunktion der App. Rechtsgrundlage: Art. 6 Abs. 1
  lit. b DSGVO.
- **Chat-Nachrichten zwischen Käufer und Verkäufer** – zur Verhandlung zu einem
  Inserat. Rechtsgrundlage: Art. 6 Abs. 1 lit. b DSGVO.
- **Absturz- und Fehlerberichte** (Sentry, ohne personenbezogene Daten –
  `sendDefaultPii: false`) – für die Stabilität der App. Rechtsgrundlage: Art. 6 Abs. 1
  lit. f DSGVO (berechtigtes Interesse).
- **Push-Benachrichtigungs-Token** (sobald Chat-Push aktiv ist) – für die
  Benachrichtigung bei neuen Nachrichten. Rechtsgrundlage: Art. 6 Abs. 1 lit. b DSGVO.

Wir erheben **keine** Standortdaten per GPS und **keine** Daten zu Werbezwecken. Es sind
keine Werbe-SDKs in der App enthalten.

## 3. Wo deine Daten verarbeitet werden

Unsere Datenbank läuft bei Supabase in der Region **eu-central-1 (Frankfurt, Deutschland)**.
Für folgende Auftragsverarbeiter liegt bzw. wird ein Auftragsverarbeitungsvertrag (AVV)
abgeschlossen:

- **Supabase** – Datenbank, Authentifizierung, Datei-Speicher, Echtzeit-Chat
- **Sentry** – Absturz- und Fehlerberichte
- **Google (Firebase Cloud Messaging)** – Push-Benachrichtigungen

> **Offene Frage für die Anwaltsprüfung:** AVVs mit allen drei Anbietern sind vor dem
> Live-Betrieb abzuschließen bzw. zu prüfen, insbesondere die Übermittlung an Google
> (FCM) im Hinblick auf etwaige Drittlandtransfers in die USA.

## 4. Wie lange wir deine Daten speichern

Kontodaten und Inserate bleiben gespeichert, solange dein Konto besteht. Nach Löschung
deines Kontos (siehe unten) werden deine Daten gelöscht, soweit keine gesetzlichen
Aufbewahrungspflichten entgegenstehen.

> **Offene Frage für die Anwaltsprüfung:** Genaue Löschfristen für Chat-Verläufe und
> archivierte Inserate sind noch festzulegen.

## 5. Deine Rechte

Du hast das Recht auf Auskunft (Art. 15 DSGVO), Berichtigung (Art. 16), Löschung
(Art. 17), Einschränkung der Verarbeitung (Art. 18), Datenübertragbarkeit (Art. 20) und
Widerspruch (Art. 21) bezüglich deiner personenbezogenen Daten. Du kannst außerdem
jederzeit Beschwerde bei einer Datenschutz-Aufsichtsbehörde einlegen.

Konto-Löschung kannst du direkt in der App unter **Profil → Einstellungen → Account
löschen** vornehmen, oder ohne installierte App über die Seite
[asm-app.de/account-loeschen](https://asm-app.de/account-loeschen). Für Auskunfts- und
sonstige Anfragen wende dich an **support@asm-app.de**.

## 6. Schriften und Drittanbieter-Inhalte

Diese Website und die App laden keine Schriften oder Skripte von Drittanbieter-Servern
zur Laufzeit (z. B. kein Google Fonts CDN) – alle Schriftdateien sind lokal eingebunden.
Diese Website setzt keine Tracking- oder Analyse-Cookies.

## 7. Kontakt

Fragen zum Datenschutz beantworten wir unter **support@asm-app.de**.
