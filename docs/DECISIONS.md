# Entscheidungslog

Eine Zeile pro Entscheidung, die **nicht** im Plan steht. **Chronologisch, neue Einträge
unten anfügen** (oberhalb des Markers am Dateiende) — so wie es seit Task 0.2 gehandhabt
wird. Die frühere Angabe "Neueste oben" widersprach der gelebten Praxis und ist korrigiert.

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

## 2026-08-29 · Task 2.1 · `AsmUser` als eigenes Domainmodell, `isAdultProvider` ausserhalb von `AuthRepository`

Der Plan nennt fuer Task 2.1 nur `auth_repository.dart` und `auth_controller.dart` als Dateien,
aber "Produziert" verlangt `AsmUser`. Angelegt als `lib/features/auth/domain/asm_user.dart`
(freezed, ohne `.g.dart`/JSON — wie `ListingFilter`, da die Quelle `supabase_flutter`s
`User`-Objekt aus dem Auth-Stream ist, keine Postgrest-Row). Das Mapping `User -> AsmUser?`
liegt in `SupabaseAuthRepository`, nicht im Domainmodell, damit die Domain-Schicht frei von
SDK-Importen bleibt.

`isAdultProvider` ist **kein** `AuthRepository`-Methodenname aus der "Produziert"-Zeile,
sondern ein eigener `FutureProvider`, der `supabase.rpc<bool>('is_adult')` direkt aufruft
(die Funktion aus `0001_profiles.sql`, die schon die Listing-Policies nutzen). Grund: die
Spaltenrechte in `0001_profiles.sql` geben `birth_date` keinen `select`-Grant (siehe Eintrag
oben zu Task 1.9) — kein Client-Feld auf `AsmUser` kann das herleiten, nur die RPC kennt den
Wert. **Noch ungetestet**, weil Task 2.1 nur Tests fuer `authStateProvider` verlangt. Wird
zuerst in Task 2.4 (Router-Guards) wirklich konsumiert — falls dort ein Test die RPC direkt
mocken soll, greift vermutlich dasselbe `PostgrestFilterBuilder`-mocktail-Problem wie in
Task 1.9 (Eintrag oben): dann denselben `RpcCaller`-Seam verwenden statt `SupabaseClient.rpc`
direkt zu mocken.

`AuthRepository.deleteAccount()` ruft schon jetzt `functions.invoke('delete-account')` auf,
obwohl die Edge Function erst in Task 2.6 entsteht — ein echter Aufruf schlaegt bis dahin mit
404 fehl. Bewusst so belassen (Interface soll vollstaendig sein, der Aufruf-Body ist trivial),
aber ungetestet.

## 2026-08-29 · Task 2.2 · Kritischer Fund: `Supabase.initialize()` fehlte komplett in `main.dart`

Beim ersten echten Emulator-Test von Task 2.2 (siehe Eintrag unten) crashte jeder Repository-
Aufruf sofort mit `Bad state: You must initialize the supabase instance before calling
Supabase.instance`. `main.dart` rief seit M0 nie `Supabase.initialize(url:, ...)` auf — nur
`SentryFlutter.init` + `runApp`. `AppConfig.supabaseUrl`/`supabaseAnonKey` und
`AppConfig.assertValid()` existierten bereits und lasen `env/dev.json` korrekt, das
Initialisieren selbst fehlte einfach. **Bis Task 2.2 ist das nie aufgefallen**, weil M0/M1
keinen einzigen echten Repository-Aufruf aus einem laufenden Screen heraus ausgeloest haben
(alle Tests mocken `SupabaseClient`, alle bisherigen Screens waren Platzhalter ohne
Datenzugriff) — Task 2.2 ist der erste Task, der `supabaseProvider` in der echten App
ueberhaupt anfasst. Fix in `main.dart`: `Supabase.initialize(url: AppConfig.supabaseUrl,
publishableKey: AppConfig.supabaseAnonKey)` als erste Zeile in `SentryFlutter.init`s
`appRunner`, vor `runApp`. `publishableKey` statt des (in supabase_flutter 2.17.2)
deprecateten `anonKey`-Parameters — gleicher Wert, aber ohne `deprecated_member_use`-Warnung
(G9 verlangt 0 Issues).

**Warum wichtig fuer kuenftige Sessions:** Jeder Task, der einen Screen mit echtem
Repository-Zugriff baut (M2 Rest, M3+), haette diesen Bug sofort reproduziert — jetzt ist er
weg, aber **nur weil Task 2.2 tatsaechlich auf einem Emulator lief statt sich auf
`flutter test` zu verlassen**. `flutter analyze` und die komplette Testsuite (102 Tests)
waren die ganze Zeit gruen, obwohl die App zur Laufzeit zu 100 % broken war. Lehre:
`flutter test` allein reicht bei diesem Projekt nicht als Fertig-Kriterium fuer UI-Tasks,
ein echter Lauf (Emulator oder Geraet) ist Pflicht — das deckt sich mit Abschnitt 5 in
`03-ARBEITEN-MIT-SONNET.md`.

## 2026-08-29 · Task 2.2 · Neue wiederverwendbare Komponenten ausserhalb von 01-DESIGN-SYSTEM.md

`AsmCheckbox` (`lib/core/widgets/asm_checkbox.dart`) ist in Abschnitt 5 des Design-Systems
nicht spezifiziert (nur Button/TextField/Chip/ListingCard/CategoryTile/ChatBubble/EmptyState).
Gebaut nur aus vorhandenen Tokens (keine neuen Farben/Radien), Farblogik an `AsmChip`s
aktiv/inaktiv-Pattern angelehnt. Wichtige Design-Entscheidung: **nur die Box selbst ist
Tap-Ziel**, nicht die ganze Zeile inkl. Label — weil das Label bei AGB/Datenschutz eigene
Links per `TapGestureRecognizer` enthaelt und ein Whole-Row-`GestureDetector` mit dem
verschachtelten Recognizer um denselben Tap konkurrieren wuerde. Getestet inkl. genau dieser
Interferenz (`asm_checkbox_test.dart`, "Tap auf einen Link im Label toggelt NICHT").

`AsmTextField` um `obscureText`, `readOnly`, `onTap` erweitert (alle optional, Default
unveraendert = alte Call-Sites bleiben unberuehrt) — fuer das Passwortfeld bzw. das
Geburtsdatum-Feld, das per Tap `showDatePicker` statt der Tastatur oeffnet. `Formatters.date()`
neu in `lib/core/utils/formatters.dart`: bewusst reine String-Interpolation mit
`padLeft`, kein `intl`-`DateFormat`, weil `DateFormat` mit benanntem Locale
`initializeDateFormatting()` braucht (sonst `LocaleDataException`) — fuer ein rein
numerisches `TT.MM.JJJJ` unnoetiges Risiko.

## 2026-08-29 · Task 2.2 · Seams fuer `showDatePicker` und `launchUrl` (gleiches Muster wie `RpcCaller`)

`RegisterScreen` nimmt `pickBirthDate`/`launchLink` als optionale Konstruktor-Parameter mit
echten Defaults, die `showDatePicker` bzw. `url_launcher`s `launchUrl` aufrufen. Grund: der
native Material-Datepicker laesst sich in Widget-Tests nur fragil ueber lokalisierte
Button-Texte ("OK"/"Abbrechen") steuern, und `launchUrl` hat ohne Platform-Mock in Tests gar
keinen Kanal (`MissingPluginException`). Gleiches Prinzip wie `RpcCaller` in
`SupabaseListingRepository` (Task 1.9, siehe oben): echten Aufruf hinter eine injizierbare
Funktion ziehen statt die schwer mockbare Fremd-API direkt zu testen. Beide Defaults real auf
dem Emulator verifiziert (Datepicker startet korrekt bei `now.year - 18`, AGB-/Datenschutz-Link
oeffnet real Chrome mit der richtigen URL).

## 2026-08-29 · Task 2.2 · "E-Mail bestätigen" als interner Zustand, `isUsernameTaken` auf `ProfileRepository`

Der Plan nennt fuer den Bestätigungs-Screen keine eigene Datei/Route — als zweiter
Build-Zweig in `_RegisterScreenState.build()` umgesetzt (`_registered`-Flag), nicht als
`GoRoute`. `/register` selbst wurde neu in `app_router.dart` verdrahtet (nicht im Plan
gelistet, aber sonst waere der Screen nie erreichbar) — `AsmRoutes.register` existierte
schon als ungenutzte Konstante.

`ProfileRepository` bekam `isUsernameTaken(String username)` (simple `select id where
username = ...`-Query, kein RPC, deshalb wie `byId`/`bySeller` ungetestet gelassen — Task 1.9s
`RpcCaller`-Problem betrifft nur `.rpc()`, nicht `.from().select()`). Dafuer erstmals
`profileRepositoryProvider` in einer neuen Datei `lib/features/profile/presentation/
profile_providers.dart` — Task 2.5 baut dort vermutlich den echten Profil-Controller,
kann diese Datei dann einfach erweitern statt sie neu anzulegen.

`AuthRepository` bekam zusaetzlich `resendConfirmation(String email)` (`auth.resend(type:
OtpType.signup)`) fuer den "Erneut senden"-Button — in Task 2.1 nicht vorgesehen, aber
naheliegende Erweiterung derselben Datei.

## 2026-08-29 · Task 2.2 · AGB-/Datenschutz-Links: externe Platzhalter-URLs (Nutzer-Entscheidung)

Die Rechtstexte existieren noch nicht (kommen erst in M7, siehe 00-SPEC.md §7 — vor
Store-Release muss ohnehin ein Anwalt drueberschauen). Auf Nachfrage hat der Nutzer sich fuer
externe Platzhalter-URLs entschieden statt reinem Text ohne Link oder einem In-App-
Platzhalterscreen: `https://asm-app.de/agb` und `https://asm-app.de/datenschutz`
(`RegisterScreen._agbLinkRecognizer`/`_datenschutzLinkRecognizer`), passend zum bereits in
Task 2.6 geplanten Muster `asm-app.de/account-loeschen`. **Zeigen bis M7 einen 404** — kein
Bug, sondern erwartet, bis die Website steht.

## 2026-08-29 · Task 2.2 · Test-Account bleibt absichtlich in der Dev-Datenbank

Die manuelle Verifikation auf dem Emulator hat einen echten Nutzer im Dev-Supabase-Projekt
angelegt: `gear_hunter_42` / `nutzer@example.de`, Geburtsdatum 29.08.2008. Wie schon bei der
`sold`-Listing aus Task 1.9 **absichtlich stehen gelassen** — harmlos ohne echte Nutzer,
nuetzlich fuer Task 2.3s Login-Tests (E-Mail ist unbestaetigt, gut um den
"E-Mail nicht bestaetigt"-Pfad zu testen). Aufraeumen bei Bedarf in Supabase Studio unter
Authentication → den Nutzer per E-Mail suchen und loeschen (cascaded das Profil).

## 2026-08-29 · Task 2.3 · `asm://reset-password` fehlte in der Supabase-Redirect-Allowlist

Task 1.1 (`e30c508`) hatte nur `asm://auth-callback` in `additional_redirect_urls`
eingetragen. Ohne `asm://reset-password` dort ebenfalls zu listen, haette Supabase den
`redirectTo`-Parameter von `resetPasswordForEmail` verworfen und auf `site_url` (`asm://`)
zurueckfallen lassen — der Task-Wortlaut verlangt aber explizit `asm://reset-password`.
Ergaenzt und mit `supabase config push` verifiziert gepusht: der ausgegebene Diff zeigte
**ausschliesslich** die eine Zeile (`additional_redirect_urls = [..., "asm://reset-password"]`),
keine der versehentlichen Rueckstellungen aus Task 1.1 (siehe Eintrag oben) ist diesmal
aufgetreten — trotzdem immer den Diff lesen, nicht nur "updated" im Status.

Die native `asm://`-Schema-Registrierung (Android-Intent-Filter, iOS `CFBundleURLTypes`)
existierte bereits vollstaendig (vermutlich aus derselben Task-1.1-Session) — dafuer musste
in Task 2.3 nichts geaendert werden.

## 2026-08-29 · Task 2.3 · Deep-Link-Session-Handling kommt automatisch von `supabase_flutter`

Kein eigener Code fuer "Deep-Link empfangen → Code gegen Session tauschen" noetig:
`supabase_flutter`s `SupabaseAuth`-Klasse (intern von `Supabase.initialize()` gestartet)
hoert bereits automatisch auf eingehende Links (`app_links`-Paket), erkennt Auth-Callbacks
an `code`/`access_token`/`error`-Parametern und ruft selbststaendig
`auth.getSessionFromUrl(uri)` auf — bestaetigt durch Lesen von
`supabase_flutter-2.17.2/lib/src/supabase_auth.dart`, nicht angenommen. Das laeuft nur,
weil `Supabase.initialize()` jetzt ueberhaupt aufgerufen wird (Task-2.2-Fix). Wichtig fuer
kuenftige Tasks: `gotrue_client.dart` unterscheidet dabei zwei Events —
`AuthChangeEvent.signedIn` fuer normale Logins/E-Mail-Bestaetigung, **und**
`AuthChangeEvent.passwordRecovery` spezifisch fuer den `asm://reset-password`-Link. Beide
sind bereits am Server (in `getSessionFromUrl`/`verifyOTP`) korrekt auseinandergehalten,
nicht erst client-seitig zu erraten.

**Eigener Code beschraenkt sich auf den globalen Redirect:** `AuthRepository.authEvents()`
(neuer, separater Stream neben `authStateChanges()` — nur hier ist der rohe
`AuthChangeEvent` noetig) + `authEventProvider` + ein `ref.listen` in `app.dart`, das bei
`signedIn` nach `/` und bei `passwordRecovery` nach `/reset-password` navigiert. Bewusst
**ein** `ref.listen` statt zwei (einer pro Zielrichtung waere naheliegend gewesen) — beide
Events koennen (in der Theorie) kurz hintereinander feuern, und mit getrennten Listenern
haette die Reihenfolge zweier `router.go()`-Aufrufe von der Riverpod-internen
Listener-Reihenfolge abgehangen. Ein Switch ueber beide Events in einem Listener macht das
deterministisch. Der Switch ist absichtlich exhaustiv (kein `default`, alle 8
`AuthChangeEvent`-Werte einzeln, inkl. des deprecateten `userDeleted` mit
`ignore`-Kommentar) statt mit `default:` — `very_good_analysis`s `no_default_cases`
verlangt das, und es zwingt dazu, ein neuer Event-Wert in einer kuenftigen
gotrue-Version bewusst einsortiert wird statt still im Default zu verschwinden.

## 2026-08-29 · Task 2.3 · `ResetPasswordScreen` selbst gebaut — Plan nannte nur die Anfrage-Seite

Der Task-Wortlaut deckt nur "Passwort vergessen → `resetPasswordForEmail`" ab, nicht was
passiert, *nachdem* der Nutzer den Reset-Link antippt. Ohne einen Screen, der nach einem
`passwordRecovery`-Event ein neues Passwort abfragt (`updatePassword`, neu auf
`AuthRepository`, ruft `auth.updateUser(UserAttributes(password: ...))`), waere "Passwort
vergessen" nicht wirklich benutzbar — der Nutzer wuerde nur eingeloggt und landete ohne
Erklaerung im Feed, das alte Passwort bliebe gueltig. Screen erreichbar ausschliesslich
ueber den globalen Redirect (keine In-App-Navigation dorthin), Route `/reset-password`
neu in `routes.dart`. Reuse von `PasswordStrengthBar` aus Task 2.2. Nach Erfolg: SnackBar
("Passwort aktualisiert", nutzt das schon vorhandene `snackBarTheme` aus `asm_theme.dart` —
kein neuer Styling-Aufwand) + Redirect nach `/`.

## 2026-08-29 · Task 2.3 · Login-Screen zeigt IMMER dieselbe Fehlermeldung, verwirft `error.message`

Anders als bei allen anderen Screens (die `error.message` direkt anzeigen) faengt
`LoginScreen._submit` jede `AppException` ab und zeigt **immer** "E-Mail oder Passwort ist
falsch" — unabhaengig vom tatsaechlichen Supabase-Fehlertext. Grund: der Task-Wortlaut
verbietet explizit, zwischen "Nutzer existiert nicht" und "Passwort falsch" zu
unterscheiden (Nutzer-Enumeration). Auch der Fall "E-Mail nicht bestaetigt" (ein
eigener, spezifischerer Supabase-Fehler, den man theoretisch anders anzeigen koennte)
bekommt bewusst dieselbe generische Meldung — der Plan-Wortlaut ("immer") war eindeutig
genug, um hier nicht selbst zu differenzieren. `ForgotPasswordScreen` folgt demselben
Prinzip fuer ihre Erfolgsmeldung ("Falls ein Konto mit dieser E-Mail-Adresse existiert...")
statt "E-Mail gesendet" nur bei existierendem Konto zu zeigen — Supabase selbst antwortet
bei `resetPasswordForEmail` schon serverseitig unabhaengig davon, ob das Konto existiert
(sonst waere die eigene client-seitige Vorsicht wirkungslos).

## 2026-08-29 · Task 2.3 · Emulator-Verifikation: zwei echte Funde, eine Luecke offen geblieben

**Fund 1:** `resetPasswordForEmail('nutzer@example.de')` (Task-2.2-Testaccount) schlug mit
`Email address "nutzer@example.de" is invalid` fehl — Supabase lehnt die Reserved-Domain
`example.*` fuer diesen Endpunkt ab (anders als bei `signUp`, das sie klaglos akzeptiert
hatte). Kein Bug, aber gut zu wissen: `example.com`/`.de`/`.org`/`.net` taugen nicht fuer
jeden Auth-Endpunkt als Test-Adresse.

**Fund 2 (deshalb Umstieg auf Mailinator):** Fuer eine echte, ansteuerbare Test-Mailbox
ohne eigenes Postfach wurde `asm-task23-verify@mailinator.com` verwendet (Mailinator ist
ein oeffentlicher, fuer genau diesen Zweck ueblicher Wegwerf-Postfach-Dienst, Inbox ohne
Login unter mailinator.com einsehbar). Die Registrierung damit schlug fehl mit
`email rate limit exceeded` — `supabase/config.toml`s `auth.rate_limit.email_sent = 2`
ist projektweit pro Stunde, nicht pro Empfaenger, und war durch Task 2.2s Tests (Signup +
"Erneut senden") bereits ausgeschoepft. Kein Bug, aber ein hartes Limit fuers manuelle
Testen in dieser Session.

**Daraus resultierende Luecke:** Der eigentliche "E-Mail-Link antippen → Deep Link → Session
gesetzt"-Rundlauf wurde **nicht** end-to-end mit einer echten E-Mail durchgespielt. Was
stattdessen verifiziert ist: (1) native `asm://`-Registrierung existiert (Android + iOS),
(2) Redirect-Allowlist ist korrekt (siehe Eintrag oben), (3) `supabase_flutter`s
Auto-Handling ist im Paket-Quellcode bestaetigt, nicht angenommen, (4) der eigene
Redirect-Listener in `app.dart` ist per Widget-Test mit einem gemockten Event-Stream fuer
beide Events (`signedIn`, `passwordRecovery`) sowie fuer "andere Events loesen nichts aus"
abgedeckt. **Nachholen, falls das je einen Unterschied macht:** eine Stunde nach den
Task-2.2/2.3-Tests warten (Rate-Limit reset) oder `auth.rate_limit.email_sent` testweise
per `supabase config push` erhoehen und danach zwingend zurueckdrehen, dann mit
`asm-task23-verify@mailinator.com` registrieren, den echten Link von mailinator.com
kopieren und via `adb shell am start -a android.intent.action.VIEW -d "<link>"` oeffnen —
sollte laut Code-Analyse zu `AuthChangeEvent.signedIn` und Redirect auf `/` fuehren.

## 2026-08-29 · Bugfix (kein Plan-Task) · `AsmTextField` zeichnete einen doppelten Rand — seit M0 vorhanden, in Task 2.3 vom Nutzer entdeckt

Nutzer meldete: Eingabefelder auf dem Registrieren-Screen sehen aus, "als hätten sie zwei
Ränder". Root Cause (per Lesen von `flutter/lib/src/material/input_decorator.dart`
bestätigt, nicht vermutet): `AsmTextField`s innerer `TextField` setzte nur
`InputDecoration(border: InputBorder.none, ...)` — die generische `border`-Eigenschaft.
`InputDecorator._buildBorder` (Zeile ~2362) nimmt aber bevorzugt die
zustandsspezifischen Border-Felder (`enabledBorder`/`focusedBorder`/`errorBorder`/
`focusedErrorBorder`), und faellt nur auf die generische `border` zurueck, wenn diese
`null` sind. Da `AsmTextField` diese vier Felder nie explizit setzte, fuellte
`InputDecoration.applyDefaults()` sie aus `AsmTheme.dark`s `inputDecorationTheme` auf
(das echte `OutlineInputBorder`s fuer genau diese vier Zustaende definiert, fuer die
Material-3-Formularfelder ausserhalb dieses Custom-Widgets gedacht). Ergebnis: der innere
`TextField` zeichnete sein eigenes, vom Theme geerbtes Rand-Rechteck **zusaetzlich** zur
`Border.all(...)` des aeusseren `Container`, horizontal eingerueckt durch dessen Padding
— zwei konzentrische abgerundete Rechtecke. Betraf **jedes** Eingabefeld in der App
(Login, Registrierung, Passwort vergessen, Neues Passwort, ...) seit `asm_text_field.dart`
in M0 entstand — nur bisher nicht aufgefallen, weil `asm_text_field_test.dart`s
Test-Wrapper ein Standard-`MaterialApp` **ohne** `AsmTheme.dark` nutzt und den Bug
strukturell gar nicht sehen konnte (die Tests pruefen nur die Border-Farbe des aeusseren
Containers, nie den inneren `TextField`).

**Fix:** alle sechs Border-Felder (`border`, `enabledBorder`, `focusedBorder`,
`errorBorder`, `focusedErrorBorder`, `disabledBorder`) explizit auf `InputBorder.none`
gesetzt, nicht nur die generische `border`. Regressionstest prueft direkt, dass alle
sechs Felder auf der Widget-Instanz `InputBorder.none` sind (theme-unabhaengig, deckt
den tatsaechlichen Mechanismus ab). Visuell auf dem Emulator verifiziert: Vorher/Nachher-
Crop-Vergleich (4×-Zoom auf eine Feldecke) zeigt vorher zwei sichtbare Randlinien, danach
eine. **Nicht angefasst:** der Test-Wrapper ohne echtes Theme — bliebe ein blinder Fleck
fuer aehnliche Theme-Leck-Bugs, aber Fix des Wrappers war nicht Teil dieser Meldung und
haette den Scope unnoetig vergroessert.

## 2026-08-29 · Task 2.4 · Altersgate-Logik gebaut, aber an keine Route angebunden

Die Regeltabelle verlangt ein Gate fuer "Kategorie mit `requires_age_18`", aber
`/category/:slug` existiert als Route erst ab M3 (Kategorien, Feed und Suche) — in
`app_router.dart` gibt es aktuell keine Kategorie-Detailroute, an die sich ein Redirect
haengen liesse. `blocksForAge({required bool requiresAge18, required bool isAdult})` in
`guards.dart` ist fertig implementiert und getestet (reine Funktion, konsumiert
`isAdultProvider` aus Task 2.1 noch nicht direkt), aber **nirgends verdrahtet**.
**Nachholen:** sobald M3 die Kategorie-Route anlegt, dort `redirect` um einen Aufruf von
`blocksForAge` erweitern (Kategorie laden, `requires_age_18` pruefen, bei `true` auf eine
noch zu bauende Alters-Sperrseite umleiten — auch die existiert noch nicht, ebenfalls ohne
Spec in `01-DESIGN-SYSTEM.md`).

## 2026-08-29 · Task 2.4 · Kein eigenes "Login-Sheet"-Widget — globaler Guard deckt den Gast-Tap auf den Create-FAB mit ab

01-DESIGN-SYSTEM.md 5.9 nennt ein "Login-Sheet" fuer den Gast-Tap auf den mittleren
BottomNav-Button, seit Task 0.6 als offener Punkt in DECISIONS.md vermerkt ("Nachziehen,
sobald M1 einen Auth-Provider liefert"). Es gibt dafuer aber weder einen eigenen Plan-Task
noch eine Component-Spezifikation (anders als z. B. Filter-Sheet/Melde-Sheet, die beide
eigene Tasks haben) — und der Akzeptanztest fuer Task 2.4 verlangt explizit einen
Seiten-Redirect (`redirect` → `/login?from=/create`), kein Sheet. Statt ein unspezifiziertes
neues Bottom-Sheet-Widget zu erfinden: der globale Auth-Guard aus `guards.dart` deckt jetzt
**jeden** Weg zu `/create` ab, auch den FAB-Tap eines Gasts (`AsmShell._CreateNavItem` pusht
weiterhin unconditional `/create`, der Guard faengt Gaeste ab und leitet zu
`/login?from=/create` um). Der Alt-Kommentar in `asm_shell.dart` ("noch nicht umsetzbar")
ist entsprechend aktualisiert. Falls spaeter doch ein echtes Bottom-Sheet gewuenscht ist
(schnellerer Login ohne volle Seitennavigation), ist das ein separates UI-Vorhaben mit
eigenem Spec-Bedarf, kein Bugfix an dieser Stelle.

## 2026-08-29 · Task 2.4 · Rueckkehr zur Zielroute nach Login ohne neuen `refreshListenable`

"Danach zurück zur Zielroute" (Regeltabelle) haette sich auch ueber einen
`GoRouterRefreshStream`/`refreshListenable` loesen lassen, der `redirect` bei jeder
Auth-Aenderung automatisch neu auswertet. Bewusst nicht gemacht: `app.dart`s bestehender
globaler Listener auf `authEventProvider` (Task 2.3, real auf dem Emulator getestet fuer
sowohl Login-Screen als auch den `asm://auth-callback` Deep Link) navigiert bei `signedIn`
bereits explizit per `router.go(...)`. Stattdessen liest dieser Aufruf jetzt den
`from`-Query-Parameter der aktuellen Route (`router.routeInformationProvider.value.uri`)
und geht dorthin statt immer zu `/` — kleinerer, risikoaermerer Diff, der den
Deep-Link-Pfad unveraendert laesst (dort ist beim Cold-Start nie ein `from` gesetzt, also
identisches Verhalten wie vorher).

## 2026-08-29 · Task 2.4 · `dart format` auf vier Dateien aus fruaheren Tasks nachgeholt

Wie schon in Task 0.7: `dart format lib test` fand Formatierungs-Drift in vier Dateien, die
in dieser Session nicht inhaltlich angefasst wurden (`asm_checkbox.dart`,
`login_screen.dart`, `register_screen.dart`, `register_screen_test.dart`) — je 4-5 Zeilen
reines Zeilenumbruch-Whitespace, keine Verhaltensaenderung. Mitformatiert, da
`dart format --set-exit-if-changed .` in CI sonst auf diesen Dateien rot gelaufen waere,
unabhaengig vom eigentlichen Task-2.4-Diff.

## 2026-08-29 · Task 2.4 · Emulator-Verifikation: Gast-Guard live bestätigt, "eingeloggt+unbestätigt"-Pfad offen gelassen

Auf dem Emulator gegen das echte Dev-Supabase-Projekt getestet: Tap auf den Create-FAB als
Gast landet korrekt auf dem Login-Screen (`redirect` greift live, nicht nur in Tests) — der
Teil mit der groessten Unsicherheit (funktioniert `ref.read(...)` innerhalb der
`GoRouter.redirect`-Closure gegen den echten ProviderContainer), damit bestaetigt.

**Nicht live durchgespielt:** die Regel "`/create` eingeloggt + unbestaetigte E-Mail →
Hinweis". Der Versuch, dafuer einen zweiten Test-Account durchzuregistrieren, wurde
abgebrochen, nachdem der Datum-Picker im Registrierungsformular ueber `adb input tap`
mehrfach nicht zuverlaessig steuerbar war (Flutter exponiert ohne aktiven Accessibility-
Service keinen `uiautomator`-Baum, blinde Koordinaten-Taps auf den Kalender-Dialog trafen
nicht zuverlaessig) — kein Zeichen eines App-Bugs, reine Automatisierungs-Reibung. Keine
Registrierung wurde abgeschickt, kein Testkonto/E-Mail-Versand ausgeloest.

**Offene Frage dabei entdeckt:** Login-Screen und `AuthRepository.signIn` gehen bisher davon
aus, dass `signInWithPassword` bei aktivierter E-Mail-Bestaetigung (Task 1.1) fuer
unbestaetigte Konten ueberhaupt eine Session liefert — Task 2.3 dokumentiert aber bereits,
dass Supabase in diesem Fall serverseitig einen eigenen Fehler wirft ("E-Mail nicht
bestaetigt"), den der Login-Screen bewusst hinter der generischen Meldung versteckt. Falls
Supabase Login fuer unbestaetigte Konten grundsaetzlich verweigert, ist die Regel
"`/create` eingeloggt+unbestaetigt" in der Praxis unerreichbar (keine Session ohne
Bestaetigung moeglich) — die Guard-Logik in `guards.dart` ist trotzdem korrekt und bleibt
als Absicherung bestehen, nur der Live-Beweis fehlt. **Nachholen:** mit einem Konto pruefen,
dessen E-Mail nachweislich unbestaetigt ist (z. B. `gear_hunter_42`/`nutzer@example.de`
aus Task 2.2, Passwort muesste dafuer erst per DB-Zugriff neu gesetzt werden, da
`resetPasswordForEmail` `example.*`-Adressen ablehnt) und beobachten, ob `signIn` ueberhaupt
erfolgreich zurueckkehrt.

## 2026-08-29 · Task 8.0 · Domain `asm-app.de` registriert — Bundle-ID bleibt `de.asmapp.asm`

`asm-app.de` ist registriert und damit **fix**. Sie wird in Impressum, Store-Einträgen,
Deep Links und den `.well-known`-Dateien verwendet; ein späterer Wechsel wäre teuer.
In allen Docs bereits konsistent verwendet (10 Fundstellen, keine Varianten).

**Die Bundle-ID bleibt `de.asmapp.asm`** — in `android/app/build.gradle.kts`
(`namespace` + `applicationId`) und in `ios/Runner.xcodeproj` (`PRODUCT_BUNDLE_IDENTIFIER`).
Sie muss der Domain **nicht** exakt entsprechen: die Reverse-DNS-Form von `asm-app.de` wäre
`de.asm-app`, aber Bindestriche sind in Java-Paketnamen nicht zulässig. `de.asmapp.asm` ist
die korrekte bereinigte Form. **Nicht "angleichen"** — nach der ersten Store-Veröffentlichung
ist die Bundle-ID unveränderlich, und schon vorher zieht eine Änderung Signing, Firebase und
Deep Links nach sich.

## 2026-08-29 · Task 8.0 Teil A · Impressum mit Platzhaltern statt erfundener Daten

`impressum.md` braucht nach § 5 DDG einen echten Namen und eine echte Postanschrift.
Sonnet kennt beides nicht zuverlässig genug, um es in ein Dokument zu schreiben, das
später live geht — eine erfundene oder geratene Adresse wäre ein Compliance-Fehler, kein
harmloser Platzhalter. Alle personenbezogenen Felder (Name, Adresse, Telefon,
Registereintrag) stehen deshalb als `[PLATZHALTER: ...]` im Text und müssen vor
Veröffentlichung vom Nutzer selbst ausgefüllt werden. Auch offen: ob ASM als
Privatperson, Kleingewerbe oder Unternehmen betrieben wird — entscheidet, welche Felder
überhaupt Pflicht sind, im Text als offene Frage für die Anwaltsprüfung markiert.

## 2026-08-29 · Task 8.0 Teil A · `tool/gen_website.dart`: eigener Markdown-Konverter statt `package:markdown`

Kein Markdown-Paket in `pubspec.yaml` vorhanden, und eins nur für dieses ~150-Zeilen-Skript
hinzuzufügen widerspräche der Regel "erst fragen bei neuen Paketen" aus `CLAUDE.md` sowie
der Plan-eigenen Schätzung "rund 60 Zeilen" für das Skript. Stattdessen ein
handgeschriebener, zeilenbasierter Konverter, der genau den in den vier Rechtstexten
verwendeten Dialekt abdeckt: `#`/`##`/`###`, straffe Listen, Zitate (`>`), `**fett**`,
`` `code` ``, `[Links](url)`, `---`. Zwei echte Bugs dabei gefunden und behoben, bevor der
generierte Output visuell im Browser geprüft wurde (nicht blind übernommen):

1. Zitat-Bug: Der Blank-Line-Handler rief bedingungslos sowohl `flushParagraph()` als
   auch `flushQuote()` auf — beide teilten sich denselben Text-Puffer, `flushParagraph()`
   lief zuerst und leerte ihn, sodass jedes `> `-Zitat als normaler Absatz gerendert wurde.
   Behoben mit einem `inQuote`-bewussten `flushBlock()`, das nur eine der beiden Funktionen
   aufruft.
2. Link-Regex-Bug: `\[(.+?)\]\((.+?)\)` ist nicht-gierig, aber `.+?` kann über andere
   `]`-Zeichen zurueckbacktracken, wenn direkt danach keine `(` folgt. In Absätzen, die
   sowohl einen `[PLATZHALTER]` (ohne Link) als auch weiter hinten einen echten
   `[Text](datei.md)`-Link enthalten, wurde der gesamte Bereich dazwischen faelschlich als
   ein einziger Link samt Linktext verschluckt. Behoben mit `[^\[\]]+`/`[^()]+` statt
   `.+?` — kann nicht über Klammern hinweg backtracken.

Ein drittes, kein Bug: mehrzeilige Blöcke wie die Adresse im Impressum (Name/Straße/PLZ
je eigene Zeile, keine Leerzeile dazwischen) wurden vom Konverter korrekt gemäß
Markdown-Semantik zu einem Fließtext-Absatz zusammengefügt — optisch aber nicht gewollt.
Nicht den Konverter um "harte Zeilenumbrüche" erweitert (hätte echte Fließtext-Absätze
anderswo genauso kaputt umgebrochen), sondern die Adressblöcke in `impressum.md` als
Aufzählungen umformuliert.

## 2026-08-29 · Task 8.0 Teil A · Landingpage ohne Screenshots und Store-Badges

Schritt 5 verlangt "drei Screenshots" und "Store-Badges (später)" auf `index.html`. Es
gibt noch keine echten App-Screenshots (`assets/images/` ist leer, der Feed existiert
architektonisch noch nicht über M0-Platzhalter hinaus) und keine Store-Einträge — beides
zu faken wäre irreführend. Stattdessen vier Feature-Karten mit Text (Kategorien,
Rechtsrahmen, Chat, Melden/Blockieren), inhaltlich aus `docs/README.md`s bereits
abgestimmter Produktbeschreibung übernommen, nicht neu erfunden. **Nachholen:** Screenshots
einbauen, sobald der Feed (M3) echte UI zum Fotografieren hat.

## 2026-08-29 · Task 8.0 Teil A · `pubspec.yaml` unverändert gelassen

`assets/legal/*.md` ist noch in keinem `assets:`-Eintrag registriert — die App lädt diese
Dateien noch nirgends zur Laufzeit (das ist Task 7.2). Eine Registrierung jetzt wäre totes
Konfigurationsgewicht ohne Verwendung. Task 7.2 ergänzt `assets/legal/` in `pubspec.yaml`,
wenn `flutter_markdown` die Dateien tatsächlich rendert.

## 2026-08-29 · Task 8.0 Teil A · Schritt 7 (Postfach) und Schritt 8 (Upload) offen — brauchen Hostinger-Zugriff

Beide Schritte verlangen Zugriff auf den Hostinger-Account des Nutzers (E-Mail-Postfach
anlegen bzw. Dateien per Dateimanager/FTP hochladen). Sonnet hat keinen Zugriff darauf und
kann das nicht automatisieren. `website/` ist lokal fertig und lokal per
`npx --yes serve website` geprüft (alle sechs Seiten, Mobile-Breite, alle Links) —
Hochladen und Postfach-Einrichtung bleiben eine manuelle Aufgabe des Nutzers.

## 2026-08-29 · Task 2.5 · Vier Unterpunkte verweisen auf spaetere, dedizierte Tasks

Wie schon bei Task 2.4 (Altersgate → M3) haengen mehrere Task-2.5-Punkte an Features, die
im Plan bereits eigene, spaetere Tasks haben. Statt sie hier vollstaendig vorwegzunehmen:

- **"Favoriten"**: eigener Screen ist Task 5.2 (M5). Hier nur ein Navigations-Eintrag zu
  `/favorites`, Ziel ist ein `_TitledPlaceholder` wie bei Chats/Suchen aus Task 0.6.
- **"Meine Inserate"**: die volle Verwaltung (Tabs Aktiv/Reserviert/Verkauft/Entwuerfe,
  Bearbeiten/Hochschieben/Status/Loeschen) ist Task 4.3. Weil `ListingRepository.bySeller`
  aber schon existiert, zeigt `MyListingsScreen` echte aktive Inserate (nur lesend, keine
  Aktionen) statt eines reinen Platzhalters — mehr Wert als ein Platzhalter, kein
  Vorgriff auf 4.3s Funktionsumfang.
- **"Melden"/"Blockieren"**: das volle Melde-Sheet mit den 9 festen Gruenden aus Task 1.5
  und Bestaetigungstext ist Task 7.1 (M7), ebenso die beidseitige Sichtbarkeits-Logik in
  Suche/Chat. Hier schon `moderation/domain/report_reason.dart` mit den neun Werten
  angelegt (im Plan bereits fixiert, verlustfrei jetzt schon nutzbar) und eine einfache,
  aber echte Melden/Blockieren-Aktion gebaut (schreibt wirklich in `reports`/`blocks`).
  Task 7.1 baut daraus das Sheet und die Sichtbarkeits-Effekte.
- **"Einstellungen"**: `_TitledPlaceholder`. Die "Liste blockierter Nutzer" darin ist
  laut Plan explizit Teil von Task 7.1.
- **"Rechtstexte"**: verlinkt extern auf `asm-app.de/*.html` (Task 8.0), gleiches Muster
  wie die AGB-/Datenschutz-Links im Registrieren-Screen. In-App-Rendering per
  `flutter_markdown` ist Task 7.2.

## 2026-08-29 · Task 2.5 · `lat`/`lng`/`commercial_address` sind wie `birth_date` schreibbar, aber nie lesbar

Task 1.2s Spalten-Grants (siehe DECISIONS.md-Eintrag zu Task 1.9) geben `lat`, `lng` und
`commercial_address` einen Update-, aber keinen Select-Grant. Zwei Konsequenzen im
Bearbeiten-Screen:

1. `commercial_address` kann nie vorausgefuellt werden. `ProfileRepository.update` nimmt
   deshalb ein freies `Map<String, dynamic>`-Patch statt eines festen DTOs — der Aufrufer
   sendet den Key nur, wenn der Nutzer in der aktuellen Sitzung tatsaechlich etwas
   eingetippt hat. Reine Entscheidungslogik dafuer in
   `profile_update_payload.dart::buildProfileUpdatePayload`, direkt getestet.
2. `lat`/`lng` waeren beim Speichern ganz ohne PLZ-Aenderung nie erneut bekannt.
   Geloest, indem `EditProfileScreen` die (vorausgefuellte oder neu getippte) PLZ **immer**
   ueber denselben `_plzController`-Listener aufloest — deterministisch aus derselben PLZ,
   reproduziert exakt das urspruenglich gespeicherte Ergebnis. Speichern bleibt deshalb
   deaktiviert, bis eine PLZ erfolgreich aufgeloest ist.

Avatar-Uploads laufen unter einem festen Dateinamen je Nutzer (`<uid>/avatar.jpg`,
`upsert: true`) statt eindeutiger Dateinamen — verhindert verwaiste alte Avatare im
Bucket, ein neuer Upload ersetzt den alten einfach.

## 2026-08-29 · Task 2.5 · Zwei echte Layout-Bugs auf schmalen Geraeten gefunden (nicht nur Test-Artefakte)

Beim Testen bei 400px Breite (realistische schmale Telefonbreite) zwei tatsaechliche
`RenderFlex`-Overflows gefunden, beide vorher unbemerkt, weil bisher nie bei dieser
Breite gepumpt wurde:

- `LoginScreen`s "Noch kein Konto? Registrieren"-`Row` (seit Task 2.3) uebersteigt die
  verfuegbare Breite. Zu `Wrap` gewechselt (faellt auf schmalen Geraeten in eine zweite
  Zeile statt abzuschneiden), keine funktionale Aenderung.
- `PublicProfileScreen`s "Melden"/"Blockieren" nebeneinander in eine `Row` mit `Expanded`
  passt nicht (Blockieren + `AsmButton`s festem `AsmSpacing.lg`-Innenabstand). Zu
  `Column` (untereinander) gewechselt.

Ausserdem: `AsmSkeleton.listingGrid()` (intern ein `GridView`) direkt als Kind einer
bereits scrollenden `ListView` verschachtelt haette in Produktion dasselbe
Nested-Scrollable-Problem gehabt, das `flutter test` sichtbar machte. Fuer die reine
"X aktive Inserate"-Zeile auf dem Fremdprofil reicht ein einzeiliger Shimmer-Platzhalter
(`_TextLineSkeleton`) — kein Grund, dafuer eine ganze Karten-Grid-Vorschau zu bauen.

## 2026-08-29 · Task 2.5 · Zwei neue Test-Stolperfallen fuer kuenftige Sessions

1. **`PlzLookup.resolve()` (echtes `rootBundle`-Laden von 425 KB) haengt innerhalb von
   `testWidgets()`**, obwohl derselbe Aufruf in einem einfachen `test()` (wie in
   `plz_lookup_test.dart`) sofort funktioniert — `testWidgets` laeuft in einer
   FakeAsync-Zone, die mit dem echten Datei-I/O des Asset-Ladens nicht sauber
   zusammenspielt. Gegenmittel: `EditProfileScreen` bekommt einen `resolvePlz`-Seam
   (Default `PlzLookup.resolve`), Tests injizieren eine synchrone Fake-Funktion — gleiches
   Prinzip wie `pickBirthDate`/`launchLink` in Task 2.2.
2. **`router.routeInformationProvider.value.uri` ist kein verlaesslicher Nachweis fuer
   `context.push(...)`, wenn der Aufrufer innerhalb eines `StatefulShellBranch` sitzt**
   (hier: von `ProfileScreen` aus zu `/my-listings`). Der Navigationswechsel geschah real
   (der Ziel-Screen rendert), aber die Route-Information aktualisierte sich im Test nicht
   zuverlaessig fuer einen direkten String-Vergleich. Stattdessen den tatsaechlich
   gerenderten Screen pruefen (`find.widgetWithText(AppBar, ...)`), wie es
   `app_router_test.dart` fuer den Guard-Redirect in Task 2.4 bereits vormacht.

Nebenbei bestaetigt, nicht neu entdeckt: `AsmCheckbox` toggelt nur ueber die Box
(`find.descendant(of: find.byType(AsmCheckbox), matching: find.byType(GestureDetector))`)
und `AsmTextField`s Label ist kein Decendant des inneren `TextField`
(`find.descendant(of: find.widgetWithText(AsmTextField, label), matching: find.byType(TextField))`)
— beide Muster existierten schon in `register_screen_test.dart`, hier nur wiederverwendet.

## 2026-08-29 · Task 2.5 · `register_screen.dart`: AGB-/Datenschutz-Links um `.html` ergaenzt

Beim Bauen der "Rechtstexte"-Links auf dem Profil-Screen aufgefallen: Die in Task 2.2
gesetzten externen Links zeigten auf `asm-app.de/agb`/`.../datenschutz` (ohne Endung),
aber `tool/gen_website.dart` aus Task 8.0 erzeugt `agb.html`/`datenschutz.html`. Beide
Stellen jetzt konsistent auf `.html`. Bis zum Hochladen (Task 8.0 Schritt 8, offen) fuehrt
das ohnehin noch zu keiner echten Seite.

## 2026-08-29 · Task 2.5 · Emulator-Verifikation: Guard und Login-Layout live bestaetigt, neue Profil-Screens nicht

Auf dem Emulator gegen das echte Dev-Supabase-Projekt getestet: Tap auf den Profil-Tab
als Gast leitet korrekt zum Login-Screen um (Task-2.4-Guard funktioniert weiterhin), und
`LoginScreen`s neu auf `Wrap` umgestellte "Noch kein Konto?"-Zeile rendert bei 1080px
Geraetebreite ohne Overflow — der Layout-Fix aus diesem Task ist damit real bestaetigt,
nicht nur in Tests.

**Nicht live durchgespielt:** `ProfileScreen`, `EditProfileScreen`, `PublicProfileScreen`
und `MyListingsScreen` selbst, weil dafuer ein eingeloggter Nutzer noetig ist und der
Versuch, dafuer ueber die UI ein neues Konto zu registrieren, am Geburtsdatum-Feld
scheiterte: der native Material-Datepicker liess sich per `adb shell input tap` nicht
zuverlaessig steuern (identisches Problem wie schon in der Task-2.4-Session mit dem
Registrieren-Screen, siehe dortiger DECISIONS.md-Eintrag — dort ebenfalls abgebrochen,
keine Registrierung abgeschickt, kein Testkonto angelegt). Die Interaktion hatte in einer
fruaheren Session einmal funktioniert (Task 2.2s DECISIONS.md-Eintrag), diesmal auch nach
mehreren Anlaeufen (Kalender-OK-Taste, Text-Eingabe-Modus ueber das Stift-Icon) nicht.

Stattdessen verlaesst sich diese Session auf die Breite der automatisierten Suite fuer
die neuen Screens (u. a. Lade-/Fehler-/Erfolgszustaende, PLZ-Aufloesung ueber einen
injizierten Seam, das `commercial_address`-Patch-Verhalten, Avatar-Upload-Fluss,
Melden/Blockieren inkl. Gast-Redirect) — alle 160 Tests gruen, `flutter analyze` 0
Probleme. **Nachholen:** sobald ein eingeloggtes Testkonto auf andere Weise verfuegbar
ist (z. B. Passwort fuer `gear_hunter_42` per DB-Zugriff neu setzen, oder
Computer-Use mit echten Maus-Events statt `adb`-Synthetic-Taps fuer den Datepicker),
alle vier Screens einmal real durchklicken.

## 2026-08-29 · Task 2.6 · `chat-images` bewusst nicht mitgeloescht, Deploy vom Classifier blockiert

**Storage-Scope:** Die Edge Function raeumt beim Account-Loeschen nur `avatars/<user_id>/...`
und `listing-images/<user_id>/...` auf (pfadseitig adressierbar). Das private
`chat-images`-Bucket ist nach `<conversation_id>` organisiert, nicht nach `user_id`
(siehe Policies in `0006_storage.sql`), und wird hier nicht gezielt geleert. Die
`conversations`/`messages`-Zeilen selbst verschwinden ueber die bestehende
`on delete cascade`-Kette (`profiles.id -> auth.users.id`, dann weiter ueber
`buyer_id`/`seller_id`/`conversation_id`), wodurch die zugehoerige RLS-Policy
(`exists (select 1 from conversations ...)`) fuer niemanden mehr durchgelassen wird,
sobald die Conversation weg ist — die Dateien selbst bleiben aber als verwaister
Storage liegen (Kostenfaktor, kein Datenleck). **Nachholen:** falls das relevant wird,
eine begleitende Aufraeum-Funktion, die vor dem User-Delete alle `conversation_id`s des
Nutzers sammelt und deren `chat-images`-Ordner leert.

**Deploy zunaechst blockiert, nach Freigabe erfolgreich:** `supabase functions deploy
delete-account --use-api` wurde erst vom Auto-Mode-Classifier abgelehnt ("Blocked by
classifier"), kein Workaround versucht. Nutzer hat die Aktion im Chat freigegeben,
zweiter Versuch war erfolgreich (Function live auf `xlpgrexkiigzqrcmkenv`).

**Teilverifikation live gemacht, volle e2e-Verifikation offen:** Zwei `curl`-Aufrufe
gegen die deployte Function ohne bzw. mit ungueltigem Bearer-Token liefern beide
korrekt `401 Invalid credentials` — bestaetigt, dass Deploy und der
`withSupabase({auth: "user"})`-Gate wirklich greifen, obwohl `verify_jwt` in
`config.toml` fuer diese Function auf `false` steht (von `supabase functions new`
selbst so generiert; das ist bei `@supabase/server`-Functions so vorgesehen, die
Lib macht die Auth-Pruefung selbst, siehe https://github.com/supabase/server).

**Nicht gemacht:** der volle destruktive Test aus dem Plan ("Login mit denselben
Daten liefert nach dem Loeschen einen Fehler") mit einem echten Nutzer. Grund:
`enable_confirmations = true` fuer E-Mail (siehe `config.toml`) bedeutet, `signUp()`
liefert keine Session, bevor der Bestaetigungslink angeklickt wurde — ohne Session
kein Access-Token, ohne Access-Token kein Aufruf der Function moeglich. Ein echter
Testlauf braucht entweder (a) einmalig ein echtes/mailinator-Postfach mit Klick auf
den Bestaetigungslink (E-Mail-Limit ist knapp, siehe Task-2.3-Eintrag), oder (b)
einen per Admin-API vorbestaetigten Nutzer, was den service_role-Key braucht und
damit dieselbe Grenze wie in der Task-1.2-Session beruehrt. **Nachholen:** eine der
beiden Optionen mit dem Nutzer abstimmen, sobald ein echter Geraetetest ansteht
(deckt sich mit der ohnehin offenen "kein Test auf echter Hardware"-Zeile oben).

## 2026-08-29 · Task 2.7 · Logo-Platzhalter, Architektur-Entscheidungen Splash/Onboarding

**Logo:** Nutzer hat ein fertiges Logo (Chrome-Schriftzug "ASM Airsoft Marketplace")
geschickt, konnte es aber nicht als Datei bereitstellen (Chat-Anhänge sind für Sonnet
nicht als Datei lesbar, nur als Bild sichtbar). Auf Nutzerwunsch mit einem Text-Platzhalter
("ASM" in `AsmTextStyles.displayL`) weitergemacht — Splash und Willkommen-Screen nutzen
denselben Platzhalter. **Nachholen:** Nutzer liefert die
Datei am Ende des Milestones (M2), dann `assets/images/`, Splash/Willkommen und
`flutter_native_splash.yaml` (`image:`-Zeile) nachziehen.

**Splash ist keine eigene GoRoute:** Der Plan nennt nur `/onboarding` als produzierte
Route, keine `/splash`. Splash sitzt deshalb als reiner Anzeige-Gate in `AsmApp`
(`app.dart`) — waehrend Session (`authStateProvider`) und Kategorien
(`rootCategoriesProvider`) noch laden, wird `SplashScreen` statt `MaterialApp.router`
gerendert, mit einem 3-Sekunden-`Timer` als Sicherheitsnetz. Das Onboarding-Gate selbst
laeuft ueber `guards.dart` (`redirect()` bekommt einen neuen optionalen
`hasSeenOnboarding`-Parameter, Default `true` um alle bestehenden Guard-Tests unveraendert
zu lassen): `/` ohne gesetztes Flag leitet zu `/onboarding` um.

**Zwei vorher fehlende Bausteine ergaenzt, nicht im Plan-Dateiumfang genannt:**
- `rootCategoriesProvider`/`categoryRepositoryProvider`
  (`lib/features/categories/presentation/category_providers.dart`) — Task 1.9 hatte nur
  das Repository, keinen Provider. Wird fuer "Splash wartet auf Kategorien" gebraucht,
  Task 3.1 wird ihn weiterverwenden.
- `sharedPreferencesProvider` (`lib/core/storage/shared_preferences_provider.dart`) --
  bewusst die neue `SharedPreferencesWithCache`-API (async `create()` einmalig in
  `main()`, danach synchrone `getBool`/`setBool`) statt der in `shared_preferences: 2.5.5`
  als "legacy" gefuehrten `SharedPreferences.getInstance()`-Singleton-API.

**Ungetesteter Rand:** Auf der letzten Onboarding-Seite ersetzt "Fertig" das
"Überspringen" — im Plan nicht explizit benannt (nur "Überspringen oben rechts"
erwaehnt), aber ohne einen Abschluss-Button waere die dritte Seite eine Sackgasse.

**Test-Ripple:** Der neue `hasSeenOnboardingProvider`-Read in `appRouterProvider`
und `rootCategoriesProvider`-Read in `AsmApp` haben bestehende Tests kompilier- bzw.
laufzeitunfaehig gemacht, die `appRouterProvider`/`AsmApp` ohne die beiden neuen
Provider-Overrides aufgebaut hatten (`app_test.dart`, `app_router_test.dart`,
`delete_account_screen_test.dart`, `profile_screen_test.dart`,
`public_profile_screen_test.dart`) — an allen Stellen einen
`sharedPreferencesProvider`-Override ergaenzt (Default `hasSeenOnboarding: true`, damit
sich am bisherigen Verhalten nichts aendert). Dafuer `test/helpers/fake_shared_preferences.dart`
angelegt (erste Datei in einem neuen `test/helpers/`-Ordner) --
`InMemorySharedPreferencesAsync` aus `shared_preferences_platform_interface`, das Paket
musste als expliziter `dev_dependency` in `pubspec.yaml` ergaenzt werden
(`depend_on_referenced_packages`-Lint). `app_test.dart` braucht zusaetzlich einen
`rootCategoriesProvider`-Override und pumpt nach dem Aufbau einmal 3 Sekunden
Fake-Zeit vor (`tester.pump(Duration(seconds: 3))`), sonst bleibt `AsmApp` dort auf
dem Splash haengen -- die dortigen Auth-Stream-Mocks emittieren nie von selbst.

<!-- Neue Einträge oberhalb dieser Zeile einfügen. -->
