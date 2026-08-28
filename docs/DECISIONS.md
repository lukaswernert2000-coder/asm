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

<!-- Neue Einträge oberhalb dieser Zeile einfügen. -->
