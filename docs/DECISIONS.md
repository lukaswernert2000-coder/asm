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

<!-- Neue Einträge oberhalb dieser Zeile einfügen. -->
