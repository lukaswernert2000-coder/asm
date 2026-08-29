# Entscheidungslog

Eine Zeile pro Entscheidung, die **nicht** im Plan steht. Neueste oben.

Diese Datei ist das Gedächtnis zwischen den Sessions. Alles, was nur im Chat besprochen
wurde, ist nach `/clear` weg — was hier steht, überlebt.

**Was hier reingehört:**
- Abweichungen vom Plan (und warum)
- Workarounds für Bugs in Paketen oder Tools
- Versionen, die gepinnt werden mussten
- Entscheidungen, bei denen es zwei plausible Wege gab
- Dinge, die absichtlich *nicht* gemacht wurden

**Was hier nicht reingehört:**
- Was im Plan steht (das steht schon im Plan)
- Was im Commit steht (dafür gibt es `git log`)
- Fortschritt (dafür gibt es die Checkboxen im Plan)

**Format:** `## YYYY-MM-DD · Task X.Y · Kurztitel` + zwei bis drei Sätze.

---

## 2026-08-28 · Task 0.2 · Kaspersky löscht `dart.exe` beim `pub get`

Kaspersky erkennt `dart.exe` während des Paket-Downloads als Bedrohung und entfernt es.
`flutter pub get` bricht dann mit unklaren Fehlern ab. **Gegenmittel:** Ausnahmen für
`C:\src\flutter` und das Projektverzeichnis in Kaspersky eintragen. Muss der Nutzer
selbst machen — das lässt sich nicht per Kommandozeile lösen. Wenn `pub get` plötzlich
ohne erkennbaren Grund scheitert: **zuerst hier nachsehen**, nicht am Paket suchen.

## 2026-08-28 · Task 0.2 · Paketversionen auf ältere Majors gepinnt

`flutter_riverpod ^2.6.1`, `riverpod_annotation ^2.6.1`, `riverpod_generator ^2.6.4`,
`riverpod_lint ^2.6.4`, `freezed_annotation ^2.4.4`, `json_annotation ^4.9.0`.
Neuere Majors brachen die Auflösung. **Nicht ohne Test hochziehen** — ein blindes
`flutter pub upgrade --major-versions` macht den Build wieder kaputt.

## 2026-08-28 · Task 0.4 · Android-Build: AGP 9.3.2 + Gradle 9.5.0 + compileSdk-Workaround

`flutter_secure_storage ^11.0.0` verlangt compileSdk 37, was AGP 9.3.2 und
Gradle 9.5.0 nötig macht (Commit `219e9f2`). Zusätzlich zwingen zwei `subprojects`-Blöcke
in `android/build.gradle.kts` alle Plugin-Module auf `compileSdk = 37`, weil einige
Plugins noch einen niedrigeren Wert festschreiben. **Diese Blöcke nicht entfernen**,
ohne den Release-Build danach komplett neu zu testen. Kotlin steht auf 2.4.0.

## 2026-08-28 · Planung · Flutter-Projekt in der Repo-Wurzel statt im Unterordner `asm/`

Ursprünglich sollte `flutter create … asm` einen Unterordner anlegen. Dann läge `docs/`
außerhalb des Flutter-Projekts und die relativen Pfade in `CLAUDE.md` würden nicht
stimmen. Stattdessen `flutter create … .` direkt in `ASM-Airsoft-Marketplace/`.

## 2026-08-28 · Task 0.5 · Kaspersky löscht `dart.exe` trotz Ausnahme — Stamp-File blockiert Reparatur

Nach Eintragen der Kaspersky-Ausnahme (siehe Eintrag oben) war `dart.exe` weiterhin weg.
Grund: `bin/cache/engine-dart-sdk.stamp` sagt Flutter "SDK aktuell", obwohl die Datei fehlt,
also bootstrapt `flutter` nicht neu. **Gegenmittel:** `bin/cache/engine-dart-sdk.stamp`
löschen, dann `flutter --version` — das erzwingt den Re-Download des Dart-SDK. Das ist ein
reiner Cache-Bookkeeping-Fix, keine Kaspersky-Ausnahme nötig.

## 2026-08-28 · Task 0.5 · `AsmTextField`-Signatur selbst festgelegt

Weder `01-DESIGN-SYSTEM.md` Abschnitt 5.2 noch der Implementierungsplan geben eine
Konstruktor-Signatur für `AsmTextField` vor. Umgesetzt mit dem Minimum, das 5.2 tatsächlich
verlangt: `{required TextEditingController controller, required String label, String? errorText, int? maxLength}`.
Kein `obscureText`/`keyboardType`/`onChanged` — dafür gibt es noch keinen Beleg in den Docs,
bei Bedarf (z. B. Login-Screen) ergänzen.

## 2026-08-28 · Task 0.5 · `AsmErrorView` und `AsmNetworkImage` ohne Abschnitt-5-Eintrag

Beide Widgets stehen in Task 0.5 "Produziert", haben aber keine Spezifikation in
`01-DESIGN-SYSTEM.md`. Umgesetzt: `AsmErrorView` ist ein duenner Wrapper um `AsmEmptyState`
(Icon `LucideIcons.wifiOff`, 48px/`textTertiary`, Retry als `AsmButton.secondary`).
`AsmNetworkImage` nutzt den Shimmer aus `AsmSkeleton` als Lade-Platzhalter und ein
24px-`LucideIcons.imageOff`-Icon in `textTertiary` bei Fehler oder `path == null` — verallgemeinert
aus der einzigen bestehenden Konvention dazu (5.4 ListingCard: "Platzhalter = Shimmer, Fehler = Icon").

## 2026-08-28 · Task 0.5 · `AsmButton.ghost` auf 48dp statt 44dp Höhe

5.1 nennt für `ghost` 44dp Höhe, G15 verlangt global mindestens 48×48dp Tap-Ziel ohne
dokumentierte Ausnahme. G15 gewinnt: `ghost` ist jetzt 48dp hoch wie `primary`/`danger`,
nur ohne Fläche/Border. Betrifft nur `ghost` — `secondary`/`danger`/`primary` waren mit
52dp bereits konform.

## 2026-08-29 · Task 0.6 · `build_runner` durch `analyzer_plugin` blockiert — `riverpod_lint` entfernt, `appRouterProvider` ohne Codegen

`dart run build_runner build` schlägt beim Kompilieren des Build-Skripts fehl:
`riverpod_generator 2.6.4` → `riverpod_analyzer_utils 0.5.9` → `custom_lint_core` →
`analyzer_plugin 0.12.0` nutzt eine `Element`-API, die unsere gepinnte `analyzer`-Version
bereits durch `Element2` ersetzt hat — ein bestätigter, offener Upstream-Bug
(dart-lang/sdk#60899, rrousselGit/riverpod#4124/#4393). Kein Analyzer zwischen 7.3 und 7.6
funktioniert gleichzeitig für `analyzer_plugin` (braucht älter) und `custom_lint_visitor`
1.0.0+7.7.0 (braucht neuer, wegen Dart-Dot-Shorthand-Syntax) — das Fenster ist leer.
**Gegenmittel:** `custom_lint`/`riverpod_lint` aus `pubspec.yaml` entfernt (IDE-Lint-Hilfe,
nicht build-kritisch) und `analysis_options.yaml`s `plugins: - custom_lint` gestrichen.
`riverpod_generator` bleibt installiert, wird aber vorerst nicht benutzt — `appRouterProvider`
in `lib/core/router/app_router.dart` ist ein klassischer `Provider<GoRouter>((ref) => …)`
ohne `@riverpod`. **Sobald diese Pakete kompatible Versionen ausliefern**: `custom_lint`/
`riverpod_lint` zurückholen und `appRouterProvider` auf `@riverpod` umstellen. Betrifft auch
`freezed`/`json_serializable` in M1 — die brauchen `build_runner` genauso und laufen erst
wieder, wenn diese Kette gelöst ist.

## 2026-08-29 · Task 0.6 · Schwebender Create-Kreis: `floatingActionButton`/`centerDocked` statt Stack

Der "erhöhte Kreis" in der BottomNav (5.9) sollte zunächst per eigenem `Stack`/`Positioned`
über der Bar schweben. Drei Anläufe (negativer Offset, Leerraum-Spacer, explizite
Gesamthöhe per `SizedBox`) haben das **visuell** jedes Mal korrekt hinbekommen — aber
**Touch-Events kamen nie an**, weder beim Kreis noch (im ersten Anlauf) bei den Labels
daneben, ohne jede Fehlermeldung oder Overflow-Warnung. `Scaffold.bottomNavigationBar`
reicht Gesten offenbar nicht zuverlässig durch, wenn die Wurzel ein `Stack` mit eigenem
`Positioned`-Overlay ist. **Gegenmittel:** Scaffolds eigenen `floatingActionButton` +
`floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked` benutzt — genau
dafür gebaut, Rendering *und* Hit-Testing funktionieren sofort. `_BottomNav` ist wieder eine
simple `Row` in `SafeArea`+`SizedBox(height: 64)` (die ursprüngliche, immer funktionierende
Form). **Lektion:** Bei "Widget X schwebt über Bar Y" in Flutter zuerst den dafür vorgesehenen
Scaffold-Slot (`floatingActionButton`, `persistentFooterButtons`, …) prüfen, bevor man das
per `Stack` nachbaut.

## 2026-08-29 · Task 0.6 · Gast-Check am Create-Button noch nicht umsetzbar

5.9 verlangt: bei Gast öffnet der mittlere Button das Login-Sheet statt `/create`. Es gibt
noch keinen Auth-Zustand (kommt erst in M1) — der Button pusht deshalb aktuell immer
`/create`, unabhängig vom (nicht existierenden) Login-Status. **Nachziehen, sobald M1 einen
Auth-Provider liefert** — voraussichtlich Task 1.x oder ein Nachtrag zu Task 0.6.

## 2026-08-29 · Task 0.7 · CI ohne `build_runner`-Schritt

Die Plan-Vorlage für `ci.yml` enthält `dart run build_runner build --delete-conflicting-outputs`.
Das schlägt lokal weiterhin fehl (siehe Eintrag zu Task 0.6, `analyzer_plugin`/`analyzer`-Konflikt)
und würde CI auf jedem Push rot färben, obwohl aktuell nichts Codegen braucht (`appRouterProvider`
ist weiterhin ein plain `Provider`). Schritt aus `ci.yml` weggelassen. **Zurückholen, sobald** die
Analyzer-Kette aus dem 0.6-Eintrag wieder kompatibel ist und `@riverpod`/`freezed` tatsächlich
verwendet werden (spätestens M1).

## 2026-08-29 · Task 0.7 · `dart format` auf 15 Dateien aus 0.5/0.6 nachgeholt

Die neue CI prüft `dart format --set-exit-if-changed .`; das schlug sofort auf 15 nie formatierten,
aber funktional unveränderten Dateien aus Task 0.5/0.6 fehl. Mit `dart format lib test` behoben,
keine Verhaltensänderung. `dart format .` (Repo-Root) scheitert lokal weiterhin, weil es versucht,
den gitignorten `build/`-Ordner (Android-Gradle-Zwischenartefakte, tiefe Pfade) zu durchsuchen —
betrifft nur lokale Checkouts nach `flutter run`, nicht CI (frischer Checkout ohne `build/`).

## 2026-08-29 · Task 0.7 · `sentry_flutter` auf 9.28.0 hochgezogen — 8.14.2 crasht beim Start

Nach Commit `9d9cdba` erstmals echt auf dem Emulator getestet (vorher nur `analyze`/`test`):
`SentryFlutter.init()` wirft auf Android bei **jedem** Start `ClassCastException: Integer
cannot be cast to Long`, unabhängig von den eigenen Optionen. Ursache gefunden in der
Plugin-Quelle im Pub-Cache: `SentryFlutter.kt:48` liest `autoSessionTrackingIntervalMillis`
als `Long`, aber der Default-Wert kommt über den Platform-Channel als 32-bit `Integer` an
(Dart-`int`, klein genug für Int32-Kodierung) — ein Bug in `sentry_flutter 8.14.2`, das
zugleich die letzte je veröffentlichte 8.x-Version ist (2024-08-26), Fix also nur über
einen Major-Sprung erreichbar. Mit `sentry_flutter ^9.28.0` (aktuell) getestet: `pub get`
löst sauber auf (keine anderen gepinnten Pakete betroffen, nur `jni`/`path_provider_android`
transitiv leicht abweichend), `flutter analyze --fatal-infos` 0 Issues, App läuft auf dem
Emulator ohne jede Sentry-Fehlermeldung. Vor dem Hochziehen mit dem Nutzer abgestimmt
(Alternative wäre `autoInitializeNativeSdk = false` auf 8.14.2 gewesen — Dart-Fehler bleiben
erfasst, aber kein natives Crash-/ANR-Tracking).

## 2026-08-29 · Task 0.6 (Nachtrag) · Widget-Katalog war eine Sackgasse

Beim manuellen Verifizieren von Task 0.7 auf dem Emulator gemeldet: Die App landet im
Debug-Build laut `app_router.dart` immer zuerst auf `GalleryScreen` (`kDebugMode ?
_galleryPath : AsmRoutes.home`), aber die Katalog-Seite hatte keinerlei Navigation zurück
zur echten App — keine Bottom-Nav, kein Link, kein Zurück-Button (sie ist die initiale
Route, also auch kein Pop möglich). Jeder normale `flutter run` blieb dort hängen; die
Bottom-Nav-Shell aus Task 0.6 war dadurch faktisch nicht erreichbar. Test-first behoben:
`AsmButton`-freier `IconButton` (Haus-Icon, Tooltip "Zur App") in der `GalleryScreen`-AppBar,
navigiert per `context.go(AsmRoutes.home)`. Mit echtem Tap auf dem Emulator verifiziert,
inklusive aller vier Tabs und dem Create-Vollbild-Flow — alle funktionieren wie spezifiziert.

## 2026-08-29 · Task 0.6 (Nachtrag 2) · `initialLocation` zeigte immer noch auf den Katalog

Der vorherige Eintrag ("Widget-Katalog war eine Sackgasse") hat nur einen Ausgang aus dem
Katalog ergänzt, aber `initialLocation: kDebugMode ? _galleryPath : AsmRoutes.home` nicht
angefasst — jeder normale `flutter run` landete also weiterhin zuerst im Katalog, nie in der
echten App. Vom Nutzer zu Recht als falsch zurückgewiesen. Jetzt echt behoben:
`initialLocation` ist immer `AsmRoutes.home`; der Katalog ist stattdessen über ein
Schraubenschlüssel-Icon oben rechts in `AsmShell` erreichbar (nur `if (kDebugMode)`,
`AsmRoutes.debugGallery`, ehemals der private `_galleryPath`-Konstante in `app_router.dart`,
jetzt in `routes.dart` neben den anderen Routen). Mit echtem Neustart auf dem Emulator
verifiziert: App landet direkt auf dem Start-Tab, Schraubenschlüssel führt zum Katalog,
Zurück-Pfeil und das bestehende Home-Icon im Katalog führen beide zurück.

Zwei Testfallen dabei gefunden: `find.text('Start')` matcht zweimal (Bottom-Nav-Label **und**
Platzhalter-Titel, weil `StatefulShellRoute.indexedStack` alle vier Branches sofort baut, nicht
nur die aktive) — Assertion auf `findsNWidgets(2)` korrigiert. Und `pumpAndSettle()` nach dem
Sprung in den Katalog hängt sich auf, weil `AsmSkeleton` dort mit einer Shimmer-Animation läuft,
die nie zur Ruhe kommt — durch zwei gezielte `pump()`-Aufrufe ersetzt.

## 2026-08-29 · Task 0.6 (Nachtrag 3) · Create-Button-Schatten auf Nutzerwunsch verkleinert

Der Schatten des Create-FAB (`4.3`-Ausnahme) wirkte dem Nutzer zu präsent. Pixelgenau
nachgemessen, bevor etwas geändert wurde: Das Plus-Icon selbst war exakt zentriert
(0,5px/0,3% Abweichung bei 145px Kreisdurchmesser — Rauschen, kein Bug). Der wahrgenommene
Versatz kam vom asymmetrischen Schatten-Offset `(0, 4)`, der unten sichtbar mehr Fläche
einnahm als oben und den Kreis optisch nach oben verschoben wirken ließ. Auf Wunsch des
Nutzers Blur und Offset halbiert: `blur 16 → 8`, `offset (0,4) → (0,2)`. Vorher/Nachher per
Screenshot-Zoom verglichen, sichtbar kleiner und symmetrischer. `01-DESIGN-SYSTEM.md`
Abschnitt 4.3 entsprechend mitgezogen, damit Spec und Code nicht auseinanderlaufen. Kein
Widget-Test ergänzt — `AsmShell` braucht einen echten `StatefulNavigationShell`, den ohne
GoRouter zu faken wäre für eine reine Konstantenänderung unverhältnismäßig; wie schon bei
der FAB-Positionierung in Task 0.6 stattdessen manuell auf dem Emulator verifiziert.

## 2026-08-29 · Task 0.8 · PLZ-Datensatz: GeoNames, gefiltert auf 8.172 echte Orte

Datenquelle: [GeoNames Postal Code Dataset](https://download.geonames.org/export/zip/DE.zip),
**CC BY 4.0** — Nutzung erfordert Attribution (Link auf geonames.org). **Muss beim
Impressum/den Rechtstexten in M7 berücksichtigt werden**, dort noch nicht eingetragen.

Der Rohdatensatz hat 23.297 Zeilen für 10.813 PLZ — deutlich mehr als die im Plan erwarteten
~8.200. Grund: Viele PLZ sind exklusive "Großkunden-Postleitzahlen" einzelner Firmen (z. B.
80788 → 40 Zeilen, alle "BMW ..."), erkennbar am **leeren `accuracy`-Feld** (im Gegensatz zu
`4`/`6`/`1` bei echten Orten). Diese Firmen-Einträge rausgefiltert (ergibt 8.172 PLZ, sehr
nah am Plan-Wert) — eine reine Firmen-PLZ hat danach keinen Eintrag mehr und `resolve()`
liefert korrekt `null` (kein Nutzer hat eine solche PLZ als Heimatadresse). Bei PLZ mit
mehreren echten Orten (ländliche Gebiete, ein PLZ deckt mehrere Dörfer ab, z. B. 15848 mit
55 Orten) den kürzesten Namen gewählt (bevorzugt den Hauptort vor zusammengesetzten
Ortsteil-Namen wie "Tauche Falkenberg"). `assets/data/plz.json`: 8.172 Einträge, 425 KB
(Ziel war <1,5 MB).

## 2026-08-29 · Task 0.8 · `flutter_localizations` fehlte

Task 0.2 (`flutter pub add flutter_localizations --sdk=flutter`) wurde in einer früheren
Session offenbar übersprungen oder ist verlorengegangen — stand nicht in `pubspec.yaml`,
obwohl im Plan vorgesehen. Ohne dieses Paket gibt es keine `GlobalMaterialLocalizations`
etc. für die generierten `AppLocalizations.localizationsDelegates`. Jetzt nachgeholt.

## 2026-08-29 · Task 1.1 · `supabase config push` überschreibt die komplette Auth-Config

`supabase config push` hat keinen Scope-Filter — es überträgt die **gesamte** `config.toml`,
nicht nur die drei beabsichtigten Felder (`site_url`, `additional_redirect_urls`,
`auth.email.enable_confirmations`). Beim ersten Push hat das drei unbeabsichtigte Werte auf
die lokalen `supabase init`-Defaults zurückgesetzt: `auth.mfa.totp.enroll_enabled`/
`verify_enabled` von `true` auf `false` (MFA deaktiviert), `auth.email.max_frequency` von
`1m0s` auf `1s` (E-Mail-Rate-Limit praktisch ausgehebelt — echtes Abuse-Risiko) und
`otp_length` von 8 auf 6. Der Diff, den `config push` selbst ausgibt, hat das sofort sichtbar
gemacht. Alle drei zurückgesetzt und erneut gepusht, zweiter Diff zeigte nur noch die
Rückstellung, dritter Push meldete "up to date" auf allen Services. **Lektion:** Vor jedem
künftigen `supabase config push` den ausgegebenen Diff lesen, nicht nur auf Erfolg prüfen —
das Kommando hat keinen `--only`/Scope-Flag, um das zu verhindern.

## 2026-08-29 · Task 1.2 · `supabase login` aus der Claude-Code-Session heraus unmöglich — Sandbox versteckt `%APPDATA%\npm`

`supabase db push` scheiterte zunächst an fehlendem Auth (`LegacyPlatformAuthRequiredError`), und der automatische Browser-Login-Flow scheitert aus dieser Session heraus grundsätzlich (`Cannot use automatic login flow inside non-TTY environments` — das Tool hat kein echtes Terminal). Beim Versuch, den Nutzer stattdessen selbst `supabase login` ausführen zu lassen, zeigte sich ein zweites, unabhängiges Problem: Der frühere `npm i -g supabase` (Task 1.1, aus einer Claude-Code-Session heraus) landete in einer für die Session unsichtbaren Sandbox-Schattenkopie von `%APPDATA%\Roaming` — `supabase` war aus jedem Tool-Aufruf heraus auffindbar, aber im echten Terminal des Nutzers schlicht nicht vorhanden. **Gegenmittel:** Nutzer hat `npm install -g supabase` und `supabase login` selbst in seinem echten Terminal ausgeführt (nicht über Claude Code) — das umgeht die Sandbox, und das resultierende Access-Token in `~/.supabase` lag außerhalb der redirect-betroffenen Ordner, dadurch für die Session wieder sichtbar. **Lektion:** Jede globale Paketinstallation unter `%APPDATA%`/`%LOCALAPPDATA%`, die über eine Claude-Code-Session läuft, ist für den Nutzer selbst unsichtbar — muss der Nutzer immer selbst im eigenen Terminal ausführen, nicht Claude überlassen.

## 2026-08-29 · Task 1.2 · Funktionale RLS-Verifikation ausgelassen — nur strukturell geprüft

Schritt 3 verlangt einen echten Test-User (Trigger legt Profil-Zeile an, RLS blockt `birth_date`
für fremde User). Der Auto-Mode-Classifier hat sowohl das Auslesen des service_role-Keys
(`--reveal`) als auch jede Berührung von `auth.users` (selbst nur Spalten-Introspektion per
`information_schema`) blockiert — zu Recht, beides ist Credential- bzw. Auth-Tabellen-Zugriff,
kein Workaround versucht. Stattdessen nur strukturell verifiziert (rein auf `public`-Katalogen,
unkritisch): Tabelle `profiles`, alle drei RLS-Policies (`profiles_select_all`,
`profiles_update_own`, `profiles_moderator_all`), der Trigger `on_auth_user_created` auf
`auth.users`, und die drei Funktionen `handle_new_user`/`is_adult`/`is_moderator` existieren
exakt wie in der Migration definiert. Nutzer hat auf Nachfrage entschieden, dass das für jetzt
reicht. **Nachholen:** Sobald ein echter Registrierungs-Flow in der App existiert (spätestens
wenn Auth-Screens gebaut werden), den funktionalen Teil einmal live nachziehen — insbesondere
den `birth_date`-Spalten-Grant gegen einen zweiten, fremden Nutzer testen.

## 2026-08-29 · Task 1.3 · `uuid_generate_v4()` nicht auffindbar — auf `gen_random_uuid()` umgestellt

`create table categories (... default uuid_generate_v4() ...)` schlug beim Push fehl:
`function uuid_generate_v4() does not exist (SQLSTATE 42883)`. Ursache: Supabase installiert
die `uuid-ossp`-Extension aus Task 1.1/0001 ins Schema `extensions`, nicht `public` — der
Such-Pfad der Migration schließt `extensions` nicht ein, ein unqualifizierter Aufruf schlägt
also fehl. Task 1.2 hatte denselben Aufruf nie ausgeführt (die `profiles.id`-Spalte hat keinen
Default), daher blieb der Bug bis jetzt unbemerkt. **Gegenmittel:** `gen_random_uuid()`
verwendet — seit Postgres 13 fest im Core (`pg_catalog`), kein Extension- oder
Schema-Problem möglich. Migration war nach dem Fehlschlag sauber zurückgerollt (keine
Teil-Tabelle), Retry lief clean durch. **Wichtig für alle folgenden Migrationen** (ab Task 1.4
nutzen `listings`/`listing_images` laut Plan denselben `uuid_generate_v4()`-Aufruf): dort
ebenfalls durch `gen_random_uuid()` ersetzen, nicht wörtlich aus dem Plan übernehmen. Die
`uuid-ossp`-Extension aus 0001 bleibt bestehen (harmlos, nur ungenutzt) — kein Grund, die
bereits angewendete Migration 0001 anzufassen.

## 2026-08-29 · Task 1.3 · Kategorien-Taxonomie hat 72 statt der im Plan geschätzten 68

Der Plan schätzt "8 Haupt- + ~60 Unterkategorien = 68", verweist für den Inhalt aber
verbindlich auf `00-SPEC.md` Abschnitt 5. Die dort vollständig ausgezählte Taxonomie hat
tatsächlich 64 Unterkategorien (4+7+6+8+12+12+9+6), macht **72** Kategorien gesamt. Spec vor
Plan-Schätzung übernommen — `00-SPEC.md` ist laut `CLAUDE.md` die Quelle für Produktentscheidungen,
die Zahl im Plan war erkennbar nur eine grobe Vorab-Schätzung ("~60"). Alle 72 Zeilen aus der
Spec 1:1 übernommen, keine ausgelassen oder erfunden. Verifiziert: Kinderzahl pro
Hauptkategorie stimmt exakt mit der Spec-Tabelle überein, Flags korrekt auf allen Ebenen vererbt.

## 2026-08-29 · Task 1.4 · Altersgate-Test (Schritt 3) wieder nur strukturell — gleicher Grund wie Task 1.2

Wie bei Task 1.2 fehlt ein echter Nutzer ohne `birth_date`, um die RLS-Policy `listings_public_read`
funktional zu testen (`auth.users` bleibt für den Classifier tabu). Stattdessen die Policy-Definition
per `pg_policies` geprüft: `qual` verlangt exakt `status in (...) and (not exists (... requires_age_18)
or is_adult())` — strukturell korrekt verdrahtet. Die Waffenrecht-Constraint (Schritt 2, der laut Plan
wichtigste Test) brauchte dagegen keine echte Identität (reine Tabellen-Check-Constraint, per Rollback-
Insert mit Zufalls-UUIDs getestet) und wurde live bestätigt. **Nachholen:** siehe die offene Notiz zu
Task 1.2 — sobald ein echter Registrierungs-Flow existiert, in einem Rutsch beides live testen:
`birth_date`-Spaltenschutz und Altersgate auf `listings`, jeweils mit einem Adult- und einem
Minderjährigen-Test-Account.

## 2026-08-29 · Task 1.8 · Echte Testdaten für die Suchfunktion — ein Test-User + 20 Inserate bleiben in der DB

Für den funktionalen Test von `search_listings()` (Text-, Kategorie-, Preis-, Radius-, Status-
und Propulsion-Filter) reichte strukturelle Prüfung nicht — die Funktion ist laut Plan "das
Herzstück des Feeds" und brauchte echte Daten. Nutzer hat dafür einen Test-User über Supabase
Studio angelegt (Auth-trigger aus Task 1.2 dabei nebenbei live bestätigt: Profil-Zeile entstand
automatisch, Username-Fallback-Pattern `user_<10 zeichen>` stimmt). Dessen `profiles.id`
(gelesen, kein `auth.users`-Zugriff nötig) trägt jetzt 20 Test-Inserate über alle 8
Hauptkategorien, 8 Städte und einen Preisbereich von 12–650 €, plus einen `reserved`- und
einen `sold`-Datensatz für den Status-Filter-Test. **Bleibt absichtlich in der Datenbank** —
harmlos in einem Projekt ohne echte Nutzer, und nützlich für spätere UI-Entwicklung. Erkennbar
an `seller_id = 'e6205490-cdb7-4ca4-b343-50adec4859d7'` bzw. Titeln wie "G36 S-AEG mit
Tuning-Gearbox". Aufräumen bei Bedarf: `delete from public.listings where seller_id =
'e6205490-cdb7-4ca4-b343-50adec4859d7';` und den User in Studio löschen (cascaded das Profil).

## 2026-08-29 · Task 1.9 · `build_runner` fuer echte Codegen zum Laufen gebracht — Dart 3.13 brach freezed 2.x, `riverpod_generator` endgueltig raus

Zwei unabhaengige Probleme, beide erst hier (erster echter Codegen-Task) sichtbar:

**1. `analyzer_plugin`-Konflikt aus Task 0.6 real gefixt, nicht nur umgangen.** `riverpod_generator`
stand weiter in `pubspec.yaml` (nur `custom_lint`/`riverpod_lint` waren entfernt) und zog beim
Kompilieren des Build-Skripts weiterhin `analyzer_plugin`/`custom_lint_core` rein, die an unserer
`analyzer`-Version scheiterten (`Element`/`Element2`-Konflikt). `@riverpod` wird nirgends echt
verwendet (nur ein Kommentar in `app_router.dart`) — `riverpod_generator` komplett aus
`dev_dependencies` entfernt, `flutter pub get` zeigte danach exakt die 5 betroffenen Pakete als
"no longer depended on". `riverpod_annotation` bleibt (reines Annotations-Paket, keine
Analyzer-Kette).

**2. Neuer, unabhaengiger Fehler: Dart 3.13 (`Primary Constructors`) macht freezed 2.x' Codegen
ungueltig.** Nach Fix 1 kompilierte das Build-Skript, aber `freezed` crashte beim Analysieren
JEDER Datei, die `package:flutter/material.dart` importiert (auch `app.dart`, das gar kein
`@freezed` hat) mit `Missing implementation of visitDotShorthandPropertyAccess` — unsere gepinnte
`analyzer 7.6.0` kennt eine Dart-3.13-Syntax nicht, die tief in Flutters eigenem SDK-Code steckt.
Zwischenloesung: `build.yaml` mit `generate_for: [lib/features/**/domain/*.dart]` fuer `freezed`
und `json_serializable`, damit der Builder gar nicht erst versucht, UI-Dateien zu analysieren.
Das allein reichte aber nicht — echte Ursache laut
[rrousselGit/freezed#1352](https://github.com/rrousselGit/freezed/issues/1352): Dart 3.13 verbietet
`final`/`var` auf nicht-deklarierenden Konstruktor-Parametern, genau das Pattern, das freezed 2.x/3.x
fuer JEDEN generierten Parameter nutzt. **Nutzer hat auf Nachfrage zugestimmt:**
`freezed` 2.5.8→4.0.0, `freezed_annotation` 2.4.4→3.1.0, `json_annotation` 4.9.0→4.12.0 (von
json_serializable 6.14.1 verlangt). Löste `analyzer` gleich mit auf 13.3.0 hoch — sauber, ohne
`flutter_riverpod`/`riverpod_annotation` zu beruehren. **Freezed 4 verlangt zusaetzlich `abstract
class X with _$X`** (vorher reichte `class X with _$X`) — sonst "Missing concrete implementations,
... make the class abstract". Alle 6 Modelle angepasst. `build.yaml`-Scoping bleibt bestehen
(sinnvoll unabhaengig vom Analyzer-Fix, spart unnoetige Arbeit).

**Nachwirkung:** Jede kuenftige Migration mit `default uuid_generate_v4()` (0003/0004 betroffen)
nutzt bereits `gen_random_uuid()` statt dessen (siehe Task-1.3-Eintrag oben) — hat mit diesem
Fix nichts zu tun, nur zur Erinnerung, falls beim Lesen Verwirrung aufkommt.

## 2026-08-29 · Task 1.9 · `PostgrestFilterBuilder` mit mocktail nicht sauber mockbar — RPC-Aufruf hinter injizierbare Funktion gezogen

`SupabaseClient.rpc()` gibt `PostgrestFilterBuilder<T>` zurueck, das `Future<T>` implementiert.
Der direkte Versuch, das mit mocktail zu mocken (`MockPostgrestFilterBuilder extends Mock
implements PostgrestFilterBuilder<T>`, dann `.then()` stubben) scheiterte mit `type 'Null' is not
a subtype of type 'Future<dynamic>'` — mocktail matcht die generische `then<R>()`-Stub-Registrierung
nicht zuverlaessig gegen den echten `await`-Aufruf. Bestaetigt als bekanntes, ungeloestes
Oekosystem-Problem: [supabase/supabase-flutter#714](https://github.com/supabase/supabase-flutter/issues/714),
Community-Empfehlung ist exakt "nicht die Chain direkt mocken, dahinter abstrahieren".
**Gegenmittel:** `SupabaseListingRepository` bekommt einen optionalen `RpcCaller`-Konstruktor-Parameter
(`Future<List<dynamic>> Function(String fn, Map<String, dynamic> params)`), der ohne Test-Override
einfach `_client.rpc()` aufruft. Tests injizieren eine simple synchrone Fake-Funktion statt
mocktail-Mocking fuer genau diesen einen Aufruf — `SupabaseClient` selbst bleibt trotzdem ein
mocktail-`Mock`. **Betrifft nur RPC-Aufrufe** (`.from().select()...` ohne `.rpc()` wurde hier nicht
getestet, koennte beim Testen aber auf dasselbe Problem laufen — dann denselben Seam-Trick anwenden).

## 2026-08-29 · Task 1.9 · Zwei nicht-triviale Modellierungs-Entscheidungen

`field_rename: snake` (global in `build.yaml`) konvertiert Ziffern-Grenzen falsch:
`requiresAge18` wurde zu `requires_age18` statt `requires_age_18` (die echte Spalte). Nur dieser
eine Fall betroffen (alle anderen Feldnamen ohne Ziffern konvertieren korrekt) — mit
`@JsonKey(name: 'requires_age_18')` explizit korrigiert. **Bei neuen Modellen mit Ziffern im
Feldnamen: generierte `.g.dart` immer gegen die echte Spalte gegenpruefen, nicht blind vertrauen.**

`Profile`-Modell enthaelt bewusst kein `birthDate` — Task 1.2s Spalten-Grant
(`grant select (id, username, ..., role, created_at, last_seen_at)`) laesst `birth_date` fuer
**niemanden** lesbar, auch nicht fuer den Profil-Eigentuemer selbst (Spalten-Grants unterscheiden
nicht zwischen eigener und fremder Zeile, nur RLS filtert Zeilen). **Noch kein Problem** (M1 zeigt
nirgends das eigene Geburtsdatum an), **wird aber zum Blocker**, sobald M2/Task 2.5 einen
Profil-Bearbeiten-Screen baut, der das Geburtsdatum vorausfuellen will. Nachziehen: entweder eine
`grant select (birth_date) ... where id = auth.uid()`-aehnliche Loesung (Postgres kann das nicht
direkt per Column-Grant, braeuchte eine eigene Policy-Funktion oder RPC) oder das Feld clientseitig
gar nicht vorausfuellen.

<!-- Neue Einträge oberhalb dieser Zeile einfügen. -->
