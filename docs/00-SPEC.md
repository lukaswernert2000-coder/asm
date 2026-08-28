# ASM – Airsoft Marketplace · Produkt-Spezifikation

**Version:** 1.0 (MVP)
**Stand:** 2026-08-28
**Status:** Grundlage für `02-IMPLEMENTATION-PLAN.md`

---

## 1. Produktvision

> **ASM ist der Marktplatz, den Airsoft-Spieler bekommen, wenn jemand die Regeln ihres Sports kennt.**

Airsoft-Spieler in Deutschland handeln gebrauchte Ausrüstung heute in Forenthreads
(airsoft-verzeichnis.de) oder auf Generalisten-Plattformen. Beide Wege haben konkrete Probleme:

| Problem heute | Was ASM anders macht |
|---|---|
| Kleinanzeigen löscht Airsoft-Inserate wegen Waffen-Policy | Fachplattform, Airsoft ist der Zweck |
| Forenthreads haben keine strukturierten Filter (Joule, Antriebsart, Kaliber) | Kategorie-abhängige Pflicht- und Filterfelder |
| Käufer weiß nicht, ob F-Kennzeichen vorhanden ist | F-Kennzeichen-Foto ist **Pflicht** bei über 0,5 J |
| Kein Schutz gegen Hehlerware | Besitznachweis-Foto (Zettel mit Nutzername + Datum) ist Pflicht |
| Chat läuft über Forum-PN, keine Push-Benachrichtigung | Nativer Realtime-Chat mit Push |
| Auf dem Handy unbrauchbar | Mobile-first, native App |

**Nordstern-Metrik:** Anzahl Inserate, die innerhalb von 14 Tagen als "verkauft" markiert werden.

---

## 2. Zielgruppe

**Primär:** Aktive Airsoft-Spieler in Deutschland, 18–40, kaufen und verkaufen mehrfach
im Jahr gebrauchte Ausrüstung. Technikaffin, mobil, kennen ASVZ.

**Sekundär:**
- Einsteiger (14–17, unter Aufsicht) – dürfen nur ASGs bis 0,5 J sehen und handeln
- Kleingewerbliche Verkäufer – müssen als solche gekennzeichnet sein

**Explizit nicht Zielgruppe (v1):** Österreich/Schweiz (andere Rechtslage), Händler mit
Shop-Anspruch, Sammler von Dekowaffen.

---

## 3. Scope

### 3.1 MVP (v1.0) – muss zum Release stehen

| # | Feature | Begründung |
|---|---|---|
| F1 | Registrierung und Login (E-Mail + Passwort, E-Mail-Verifizierung) | Grundlage für alles |
| F2 | Nutzerprofil (Nutzername, Avatar, PLZ/Ort, Bio, gewerblich ja/nein) | Vertrauen |
| F3 | Altersbestätigung 18+ (Geburtsdatum, Selbstauskunft) | Rechtlich zwingend für über 0,5 J |
| F4 | Account-Löschung in der App | Store-Pflicht (Apple + Google) |
| F5 | Kategorie-Browsing (8 Haupt-, ca. 60 Unterkategorien) | Kernnavigation |
| F6 | Inserat erstellen: bis 12 Fotos, Titel, Beschreibung, Preis, Zustand, Attribute | Kernfunktion |
| F7 | Pflicht-Foto F-Kennzeichen bei über 0,5 J | Rechtlich + Vertrauen |
| F8 | Pflicht-Foto Besitznachweis | Anti-Hehlerware |
| F9 | Inserat bearbeiten, pausieren, als verkauft markieren, löschen | Lebenszyklus |
| F10 | Suche (Volltext deutsch) + Filter (Kategorie, Preis, Zustand, Joule, Antriebsart, Umkreis, Versand) | Kernfunktion |
| F11 | Sortierung (neueste, Preis auf/ab, Entfernung) | Kernfunktion |
| F12 | Detailseite mit Bildergalerie, Verkäufer-Karte, Attributliste | Kernfunktion |
| F13 | Favoriten / Merkliste | Retention |
| F14 | Realtime-Chat Käufer und Verkäufer, pro Inserat | Explizit gewünscht |
| F15 | Push-Benachrichtigung bei neuer Nachricht | Chat ist ohne Push tot |
| F16 | Nutzer blockieren | Store-Pflicht (UGC) |
| F17 | Inserat und Nutzer melden, Bearbeitung unter 24 h | Store-Pflicht (UGC) + DSA |
| F18 | Rechtstexte: Impressum, Datenschutz, AGB, Nutzungsbedingungen (EULA) | Rechtlich zwingend |
| F19 | Onboarding (3 Screens) + leere Zustände | Erste App-Erfahrung |
| F20 | Offline-Fehlerbehandlung, Ladeskelette, Retry | Qualitätsminimum |

### 3.2 Post-MVP (v1.1+) – bewusst verschoben

| Feature | Warum verschoben |
|---|---|
| Bewertungssystem (Sterne nach Deal) | Braucht Transaktionsnachweis, sonst manipulierbar |
| Gespeicherte Suchen + Push bei neuem Treffer | Bester Retention-Hebel, aber erst sinnvoll bei genug Inseraten |
| Bezahlung / Treuhandservice | Löst Zahlungsdiensteaufsicht (ZAG/PSD2) aus – eigenes Projekt |
| Versandlabel-Integration (DHL) | Erst mit Zahlung sinnvoll |
| Händler-/Shop-Profile mit Impressum | Braucht Gewerbe-Verifizierung |
| Web-Version | Flutter Web ist SEO-schwach; später separate Landingpage |
| Social Login (Apple/Google) | Apple erzwingt "Sign in with Apple" nur, **wenn** ein anderer Social-Login existiert. Kein Social-Login = kein Zwang. Spart im MVP viel Arbeit. |
| Mehrsprachigkeit (EN) | i18n-Struktur wird im MVP vorbereitet, ausgeliefert wird nur Deutsch |
| Sammelbestellungen / Gruppenkauf | ASVZ-Spezialfall mit komplexem Regelwerk |

### 3.3 Nicht-Ziele (dauerhaft)

- Kein Handel mit scharfen Waffen, Munition, entmilitarisierten Waffen, Heißgaswaffen
- Kein Handel mit Artikeln ohne Airsoft-Bezug
- Keine Dienstleistungen (Techwork) im MVP
- Keine Zahlungsabwicklung in der App

---

## 4. Rollen und Berechtigungen

| Rolle | Darf |
|---|---|
| **Gast** (nicht eingeloggt) | Kategorien und Inserate bis 0,5 J ansehen, suchen. Kein Chat, keine Favoriten, kein Inserieren. Inserate über 0,5 J zeigen eine Alters-Sperre mit Login-Aufforderung. |
| **Nutzer (unverifiziert)** | Wie Gast + Profil anlegen. Inserieren erst nach E-Mail-Bestätigung. |
| **Nutzer (verifiziert, unter 18)** | Nur Kategorie "ASGs bis 0,5 J" sehen und handeln. |
| **Nutzer (verifiziert, 18+)** | Alles: inserieren, chatten, favorisieren, melden. |
| **Gewerblicher Nutzer** | Wie 18+, muss zusätzlich Firmenname und Anschrift hinterlegen; Inserate tragen Badge "Gewerblich". |
| **Moderator** | Inserate sperren/entsperren, Meldungen bearbeiten, Nutzer sperren. Im MVP über Supabase Studio, kein eigenes Backoffice. |

> **Umsetzungshinweis:** Rollen liegen in `profiles.role` (`user` / `moderator`) und werden
> über Postgres Row-Level-Security durchgesetzt – **nicht** nur im Client. Ein Client-seitiger
> Check ist reine Kosmetik und wird von jedem mit einem HTTP-Client umgangen.

---

## 5. Kategorie-Taxonomie

Die 8 Hauptkategorien sind exakt die des ASVZ-Marktplatzes (Recherche 2026-08-28,
Angebotszahlen zur Größenordnung). Die Unterkategorien sind aus den ASVZ-Unterforen
und den Shop-Taxonomien von Begadi/softairstore abgeleitet.

**Slug-Konvention:** kleingeschrieben, ASCII, Bindestriche. Slugs sind **stabil** und dürfen
sich nach dem Launch nicht mehr ändern (Deep Links).

### 5.1 `asg-05j` — ASGs bis 0,5 J (~245 Angebote)

*Frei ab 14 J. unter Aufsicht. Einzige Kategorie ohne 18+-Gate.*

| Slug | Name |
|---|---|
| `asg-05j-langwaffen` | Gewehre & MPs bis 0,5 J |
| `asg-05j-pistolen` | Pistolen bis 0,5 J |
| `asg-05j-shotguns` | Shotguns bis 0,5 J |
| `asg-05j-sonstige` | Sonstige bis 0,5 J |

### 5.2 `langwaffen` — Gewehre & MPs (~1.290 Angebote)

*Über 0,5 J. 18+, F-Kennzeichen-Foto Pflicht.*

| Slug | Name |
|---|---|
| `langwaffen-saeg` | S-AEG (Elektro) |
| `langwaffen-gbbr` | GBBR (Gas) |
| `langwaffen-hpa` | HPA |
| `langwaffen-federdruck` | Federdruck & Sniper |
| `langwaffen-shotgun` | Shotguns |
| `langwaffen-support` | Support & LMG |
| `langwaffen-sonstige` | Sonstige Langwaffen |

### 5.3 `pistolen` — Pistolen (~384 Angebote)

*Über 0,5 J. 18+, F-Kennzeichen-Foto Pflicht.*

| Slug | Name |
|---|---|
| `pistolen-gbb` | GBB (Gas) |
| `pistolen-co2` | CO2 |
| `pistolen-aep` | AEP (Elektro) |
| `pistolen-federdruck` | Federdruck |
| `pistolen-revolver` | Revolver |
| `pistolen-sonstige` | Sonstige Pistolen |

### 5.4 `ersatzteile-tuning` — Ersatzteile & Tuning (~1.709 Angebote)

| Slug | Name |
|---|---|
| `tuning-gearbox` | Gearbox & Internals |
| `tuning-externals` | Externals & Body |
| `tuning-hopup-laeufe` | Hop-Up & Läufe |
| `tuning-motoren-elektronik` | Motoren, MOSFET & Elektronik |
| `tuning-federn-kolben` | Federn, Kolben & Zylinder |
| `tuning-hpa-komponenten` | HPA-Komponenten (Engine, Regulator, Line) |
| `tuning-gbb-teile` | GBB-Ersatzteile (Nozzle, Valve, Dichtungen) |
| `tuning-werkzeug-wartung` | Werkzeug, Öle & Wartung |

### 5.5 `zubehoer` — Zubehör (~1.160 Angebote)

| Slug | Name |
|---|---|
| `zubehoer-magazine` | Magazine |
| `zubehoer-akkus-ladegeraete` | Akkus & Ladegeräte |
| `zubehoer-gas-co2` | Gas & CO2 |
| `zubehoer-bbs` | BBs & Munition |
| `zubehoer-zielhilfen` | Zielhilfen (Red Dot, ZF, Laser) |
| `zubehoer-lampen-ir` | Lampen & IR-Illuminatoren |
| `zubehoer-slings-holster` | Slings & Holster |
| `zubehoer-griffe-schaefte` | Griffe, Schäfte & Rails |
| `zubehoer-suppressor-tracer` | Suppressor & Tracer |
| `zubehoer-granaten-minen` | Granaten & Minen |
| `zubehoer-funk` | Funk & Comms |
| `zubehoer-sonstiges` | Sonstiges Zubehör |

### 5.6 `ausruestung` — Ausrüstung (~2.871 Angebote, größte Kategorie)

| Slug | Name |
|---|---|
| `ausruestung-plattentraeger` | Plattenträger & Westen |
| `ausruestung-chestrigs` | Chest Rigs |
| `ausruestung-pouches` | Pouches & Taschen |
| `ausruestung-guertel` | Gürtel & Battle Belts |
| `ausruestung-rucksaecke` | Rucksäcke |
| `ausruestung-schutzbrillen` | Schutzbrillen & Masken |
| `ausruestung-helme` | Helme & Zubehör |
| `ausruestung-protektoren` | Knie-, Ellenbogen- & Handschutz |
| `ausruestung-nachtsicht` | Nachtsicht & Thermal |
| `ausruestung-hydration` | Hydration |
| `ausruestung-feldausruestung` | Feldausrüstung & Camping |
| `ausruestung-waffentaschen` | Waffentaschen & Transport |

### 5.7 `bekleidung` — Bekleidung (~829 Angebote)

| Slug | Name |
|---|---|
| `bekleidung-combatshirts` | Combat Shirts |
| `bekleidung-hosen` | Hosen |
| `bekleidung-jacken` | Jacken & Parkas |
| `bekleidung-ghillie` | Ghillie & Tarnmaterial |
| `bekleidung-schuhe` | Stiefel & Schuhe |
| `bekleidung-kopfbedeckung` | Caps, Boonies & Kopftücher |
| `bekleidung-handschuhe` | Handschuhe |
| `bekleidung-patches` | Patches & Abzeichen |
| `bekleidung-sonstiges` | Sonstige Bekleidung |

### 5.8 `sonstiges` — Sonstiges (~328 Angebote)

| Slug | Name |
|---|---|
| `sonstiges-gesuche` | Gesuche |
| `sonstiges-konvolute` | Konvolute & Restposten |
| `sonstiges-literatur` | Literatur & Medien |
| `sonstiges-deko` | Deko & Replikate (ohne Funktion) |
| `sonstiges-tickets` | Event-Tickets & Spieltage |
| `sonstiges-diverses` | Diverses |

### 5.9 Kategorie-Metadaten

Jede Kategorie trägt Flags, die Formular und Sichtbarkeit steuern:

```text
requires_age_18       bool  -- Inserat nur für 18+ sichtbar und erstellbar
requires_f_marking    bool  -- F-Kennzeichen-Foto ist Pflichtupload
requires_joule        bool  -- Joule-Angabe ist Pflichtfeld
requires_propulsion   bool  -- Antriebsart ist Pflichtfeld
```

| Hauptkategorie | age_18 | f_marking | joule | propulsion |
|---|---|---|---|---|
| ASGs bis 0,5 J | nein | nein | ja | ja |
| Gewehre & MPs | ja | ja | ja | ja |
| Pistolen | ja | ja | ja | ja |
| Ersatzteile & Tuning | nein | nein | nein | nein |
| Zubehör | nein | nein | nein | nein |
| Ausrüstung | nein | nein | nein | nein |
| Bekleidung | nein | nein | nein | nein |
| Sonstiges | nein | nein | nein | nein |

---

## 6. Datenfelder und Wertelisten

### 6.1 Zustand (`condition`) — exakt die ASVZ-Stufen

| Wert | Label | Status-Token |
|---|---|---|
| `neu` | Neu | success |
| `neuwertig` | Neuwertig | success |
| `gebraucht` | Gebraucht | neutral |
| `leichte_defekte` | Leichte Defekte | warning |
| `defekt` | Defekt | danger |
| `bastelobjekt` | Bastelobjekt | danger |

### 6.2 Antriebsart (`propulsion`)

`saeg` (S-AEG) · `aep` (AEP) · `gbb` (GBB / Gas) · `co2` (CO2) · `hpa` (HPA) ·
`federdruck` (Federdruck) · `sonstige` (Sonstige)

### 6.3 Inserat-Status (`status`)

| Wert | Bedeutung | Für andere sichtbar |
|---|---|---|
| `draft` | Entwurf, noch nicht veröffentlicht | nein |
| `active` | Aktiv | ja |
| `reserved` | Reserviert | ja, mit Badge |
| `sold` | Verkauft | ja, 30 Tage, dann Archiv |
| `archived` | Vom Nutzer archiviert | nein |
| `blocked` | Von Moderation gesperrt | nein |

### 6.4 Felder pro Inserat

| Feld | Typ | Pflicht | Regeln |
|---|---|---|---|
| `title` | Text | ja | 10–80 Zeichen. Kein reines CAPS, keine Telefonnummern oder E-Mails |
| `description` | Text | ja | 30–5000 Zeichen |
| `price_cents` | Integer | ja | 0 bis 1.000.000 EUR. `0` nur wenn `is_giveaway` |
| `negotiable` | Bool | nein | "VB" |
| `is_giveaway` | Bool | nein | "Zu verschenken" |
| `accepts_swap` | Bool | nein | "Tausch möglich" |
| `condition` | Enum | ja | siehe 6.1 |
| `manufacturer` | Text | nein | Freitext mit Autocomplete aus bestehenden Werten |
| `model` | Text | nein | Freitext |
| `joule` | Decimal(4,2) | kategorieabhängig | 0,10 bis 7,50 |
| `propulsion` | Enum | kategorieabhängig | siehe 6.2 |
| `caliber` | Enum | nein | `6mm` oder `8mm` |
| `has_f_marking` | Bool | kategorieabhängig | Muss `true` sein, wenn `joule > 0.5` |
| `ships` | Bool | eines von beiden | Versand möglich |
| `pickup_only` | Bool | eines von beiden | Nur Abholung |
| `postal_code` | Text(5) | ja | Deutsche PLZ, gegen bundled Datensatz validiert |
| Bilder | 1–12 | mindestens 1 | JPEG/PNG/HEIC, max 10 MB Original, wird auf max 1600 px bei 80 % komprimiert |
| F-Kennzeichen-Bild | 1 | kategorieabhängig | Eigener Bildtyp, muss F-im-Fünfeck, Importeur, Kaliber und Modell zeigen |
| Besitznachweis-Bild | 1 | ja | Handschriftlicher Zettel mit ASM-Nutzername und tagesaktuellem Datum neben dem Artikel |

---

## 7. Recht und Compliance

> ⚠️ **Recherche-Ergebnisse, keine Rechtsberatung.** Vor dem Store-Release muss ein Anwalt
> für IT-/Waffenrecht über AGB, Datenschutzerklärung und Compliance-Konzept schauen.
> Budget dafür einplanen (Größenordnung 1.500–3.000 EUR).

### 7.1 Deutsches Waffenrecht — was in die App muss

| Regel | Umsetzung in ASM |
|---|---|
| Über 0,5 J = "freie Waffe", Erwerb und Besitz erst ab 18 | 18+-Gate auf Kategorien mit `requires_age_18` |
| Über 0,5 J bis max. 7,5 J braucht **F im Fünfeck** (PTB-Zulassung) | Pflicht-Foto, `has_f_marking` muss true sein |
| Über 0,5 J darf **nur halbautomatisch** feuern | Hinweistext im Inserat-Formular, Meldegrund "Vollautomat" |
| Unter 0,5 J: Anscheinswaffe nach §42a WaffG – Führen in der Öffentlichkeit verboten | Hinweis im Onboarding und in den Nutzungsbedingungen |
| Transport nur in verschlossenem Behältnis | Hinweis auf der Inserat-Detailseite bei über 0,5 J |
| Umbau der Antriebsart braucht Büchsenmacher-Bescheinigung + Beschussamt-Abnahme (ASVZ §5) | Checkbox "umgebaut" + Pflicht-Hinweisfeld |
| Verboten: Heißgaswaffen, entmilitarisierte Waffen, scharfe Waffen, Munition | Nutzungsbedingungen + Meldegründe + Moderationsregel |

**MVP-Umsetzung des Altersgates:** Geburtsdatum bei Registrierung + Bestätigung der
Nutzungsbedingungen. Keine Ausweisprüfung. Das ist der Branchenstandard für Classifieds
(auch ASVZ arbeitet mit Selbstauskunft), aber dokumentiere die Entscheidung.
**Post-MVP-Option:** Integration eines Altersverifizierungsdienstes (z. B. Nect, IDnow)
für Verkäufer in den Waffen-Kategorien.

### 7.2 Store-Guidelines — die häufigsten Ablehnungsgründe

**Apple App Store Review Guideline 1.2 (User-Generated Content)** — eine App mit UGC wird
abgelehnt, wenn nicht **alle vier** Punkte erfüllt sind:

1. Methode, um anstößige Inhalte zu filtern
2. Mechanismus, um anstößige Inhalte zu melden, mit zeitnaher Reaktion
3. Möglichkeit, missbräuchliche Nutzer zu blockieren
4. Veröffentlichte Kontaktmöglichkeit zum Entwickler

→ Deshalb sind F16, F17 und F18 **MVP-Pflicht**, nicht "nice to have".

**Apple Guideline 1.1.7 / Waffen** — Apple lehnt Apps ab, die den Verkauf von Waffen
ermöglichen. Airsoft-Geräte sind keine Waffen im Sinne dieser Richtlinie, aber die
Review-Praxis ist unberechenbar.
→ **Vorbereitung:** In den App-Review-Notizen erklären, dass es sich um Sportgeräte nach
deutschem Recht handelt (unter 7,5 J, F-Kennzeichen, Sportartikel), dass ein 18+-Gate
existiert und dass keine Zahlungsabwicklung stattfindet. Screenshots des Altersgates
beilegen. Vergleichbare Apps als Präzedenz benennen.

**Account-Löschung** — Apps mit Registrierung müssen Account-Löschung **in der App**
anbieten (Guideline 5.1.1(v)). Google Play verlangt zusätzlich eine **Web-URL** zur
Löschanfrage.
→ F4 plus eine öffentliche Seite `asm-app.de/account-loeschen`.

**Google Play Datensicherheits-Formular** — muss exakt zum tatsächlichen Verhalten passen.
→ In M8 aus dem Code ableiten, nicht raten.

### 7.3 DSGVO

| Anforderung | Umsetzung |
|---|---|
| Datenverarbeitung in der EU | Supabase-Projekt in Region **eu-central-1 (Frankfurt)** anlegen |
| Auftragsverarbeitungsvertrag (AVV) | Mit Supabase, Sentry, Google (FCM) abschließen |
| Datenschutzerklärung | Eigene Seite, in der App verlinkt und beim Registrieren bestätigt |
| Auskunfts- und Löschrecht | Account-Löschung (F4) + Datenexport per Support-Mail |
| Datenminimierung Standort | **Keine GPS-Berechtigung im MVP.** Nutzer gibt PLZ ein, Koordinaten kommen aus einem in der App gebündelten PLZ-Datensatz. Spart Berechtigungsdialog, Store-Fragen und Rechtsrisiko. |
| Keine Drittanbieter-Fonts zur Laufzeit | Schriften als Asset bündeln, **nicht** `google_fonts` mit Runtime-Download verwenden (überträgt IP-Adressen an Google) |
| Einwilligung Tracking | Sentry ohne PII konfigurieren (`sendDefaultPii: false`), keine Werbe-SDKs |

### 7.4 Digital Services Act (DSA)

Als Online-Plattform mit Nutzerinhalten in der EU brauchst du ein
**Melde- und Abhilfeverfahren** (Art. 16), eine **Begründung bei Sperrung** (Art. 17)
und eine **Kontaktstelle**. F17 deckt das technisch ab; die AGB müssen den Prozess
beschreiben.

### 7.5 Impressum

Impressumspflicht nach §5 DDG. Muss in der App erreichbar sein (nicht nur auf der Website).
Bei gewerblichen Verkäufern: deren Impressumsdaten im Profil anzeigen.

---

## 8. Nicht-funktionale Anforderungen

| Bereich | Ziel |
|---|---|
| **Start bis interaktiv** | unter 2,5 s auf Mid-Range-Android (z. B. Pixel 6a) |
| **Feed-Scrolling** | 60 fps, keine Jank-Frames über 16 ms beim Scrollen von 100 Karten |
| **Bild-Upload** | 12 Fotos in unter 30 s bei 10 Mbit/s Upload; Komprimierung on-device vor Upload |
| **Offline** | Jeder Screen zeigt bei fehlendem Netz einen Fehlerzustand mit Retry-Button, keinen Endlos-Spinner |
| **Barrierefreiheit** | Alle Texte mindestens 4,5:1 Kontrast, alle Tap-Ziele mindestens 48×48 dp, Semantik-Labels an allen Icon-Buttons, funktioniert mit Textskalierung bis 200 % |
| **Plattform-Minimum** | iOS 14+, Android 8 (API 26)+ |
| **Sprache** | Deutsch. i18n-Struktur (`.arb`-Dateien) von Anfang an, damit EN später ohne Refactoring möglich ist |
| **Crash-freie Sessions** | über 99,5 % (Sentry) |
| **Sicherheit** | Alle Datenzugriffe über Row-Level-Security. Kein Service-Role-Key in der App. |

---

## 9. Erfolgskriterien für v1.0

Die App gilt als fertig, wenn:

1. Ein neuer Nutzer kann sich registrieren, E-Mail bestätigen, ein Inserat mit 5 Fotos
   erstellen und es im Feed wiederfinden – auf einem echten iPhone und einem echten
   Android-Gerät.
2. Ein zweiter Nutzer kann dieses Inserat finden, favorisieren, den Verkäufer anschreiben,
   und der Verkäufer bekommt eine Push-Benachrichtigung.
3. Ein Inserat über 0,5 J lässt sich **nicht** ohne F-Kennzeichen-Foto veröffentlichen.
4. Ein nicht eingeloggter Nutzer sieht keine Inserate über 0,5 J.
5. Ein gemeldetes Inserat erscheint in der Moderationsliste.
6. Ein Nutzer kann seinen Account löschen und die Daten sind weg.
7. `flutter test` und `flutter test integration_test` laufen grün.
8. `flutter analyze` meldet 0 Fehler und 0 Warnungen.
9. Alle vier Rechtstexte sind in der App erreichbar.
10. Die App läuft in TestFlight und im Play-Internal-Testing-Track.
