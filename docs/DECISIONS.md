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

<!-- Neue Einträge oberhalb dieser Zeile einfügen. -->
