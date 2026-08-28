# So setzt ihr das mit Sonnet 5 um

Für dich, nicht für Sonnet. Wenn das eure erste App ist, ist *wie* ihr arbeitet fast so
wichtig wie *was* ihr baut.

---

## 1. Die wichtigste Regel: ein Meilenstein = eine Session

Sonnet arbeitet am besten mit **klarem, begrenztem Auftrag**. Wirf ihm nicht den ganzen
Plan hin und sag "bau die App". Das produziert viel Code, der nach drei Tagen niemand
mehr versteht — auch Sonnet nicht.

**Stattdessen:**

| Umfang | Ergebnis |
|---|---|
| ❌ "Bau mir die App nach dem Plan" | Halbfertige Features quer über alle Meilensteine, kaputte Tests |
| ⚠️ "Mach Meilenstein M4" | Geht, aber die Session wird sehr lang und der Kontext läuft voll |
| ✅ "Mach Task 4.1 aus dem Plan" | Überschaubar, testbar, reviewbar, sauber committet |

**Ein Task pro Auftrag. Nach jedem Task: committen, kurz anschauen, weiter.**
Wenn ein Task zu klein wirkt — gut. Kleine Schritte sind der Grund, warum du am Ende
noch weißt, was in deiner App passiert.

---

## 2. Lege als Allererstes eine `CLAUDE.md` im Projekt an

Das ist der größte Hebel überhaupt. Die Datei wird bei **jeder** Session automatisch
geladen. Ohne sie erklärst du jedes Mal von vorn, was das Projekt ist.

Leg diese Datei als `CLAUDE.md` in die **Repo-Wurzel** (`ASM-Airsoft-Marketplace/`),
neben `pubspec.yaml` — **nicht** in `docs/`:

```markdown
# ASM – Airsoft Marketplace

Flutter-App (iOS + Android) für den Handel mit gebrauchter Airsoft-Ausrüstung.
Backend: Supabase. State: Riverpod 2 mit Codegen. Routing: go_router.

## Vor jeder Aufgabe lesen
- `docs/02-IMPLEMENTATION-PLAN.md` – der verbindliche Plan. Arbeite Task für Task.
- `docs/01-DESIGN-SYSTEM.md` – Farben, Typografie, Komponenten. Nichts dazuerfinden.
- `docs/00-SPEC.md` – Produktentscheidungen, Kategorien, Rechtsanforderungen.

## Harte Regeln
- Dark-Theme only. Keine Farb-, Größen- oder Abstands-Literale in Widgets –
  immer AsmColors / AsmSpacing / AsmRadius / AsmTextStyles.
- Alle sichtbaren Texte auf Deutsch und in `lib/l10n/app_de.arb`, nie hartcodiert.
- Jede Postgres-Tabelle hat RLS mit mindestens einer Policy.
- Der service_role-Key kommt niemals in Client-Code.
- Test zuerst, dann Implementierung. Kein Task ohne Test.
- `flutter analyze` muss 0 Issues melden, bevor du committest.
- Commits im Conventional-Commits-Format.

## Befehle
```bash
flutter run --dart-define-from-file=env/dev.json
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter analyze
supabase db push
```

## Wenn du unsicher bist
Frag mich, statt zu raten. Besonders bei: Rechtsfragen, Datenmodell-Änderungen,
neuen Paketen, allem was Geld kostet.
```

---

## 3. Fertige Prompts zum Kopieren

### Session-Start (jedes Mal, wenn du Claude Code neu öffnest)

```
Lies docs/02-IMPLEMENTATION-PLAN.md und docs/01-DESIGN-SYSTEM.md.
Wir sind bei Meilenstein M{X}. Alle Tasks bis {letzter erledigter Task} sind fertig
und committet.

Führe jetzt Task {X.Y} aus. Halte dich exakt an die Schritte im Plan:
Test zuerst, dann Implementierung, dann flutter analyze, dann Commit.

Erkläre mir am Ende in drei Sätzen, was du gebaut hast und was ich testen soll.
```

### Wenn ein Task größer ist als gedacht

```
Bevor du anfängst: Zerlege Task {X.Y} in Teilschritte und zeig mir die Liste.
Fang erst an, wenn ich zustimme.
```

### Review nach jedem Meilenstein

```
Meilenstein M{X} ist fertig. Mach einen Review, bevor wir weitergehen:

1. Läuft `flutter analyze` mit 0 Issues? Zeig mir die Ausgabe.
2. Laufen alle Tests grün? Zeig mir die Ausgabe.
3. Gibt es Farb-, Größen- oder Text-Literale in Widgets, die ins Design-System gehören?
4. Gibt es hartcodierte deutsche Strings außerhalb von app_de.arb?
5. Ist jede neue Tabelle durch RLS geschützt?
6. Welche Abkürzung hast du genommen, die uns später weh tut?

Sei ehrlich bei Punkt 6. Ich will es jetzt wissen, nicht in acht Wochen.
```

### Wenn etwas nicht funktioniert

```
{Was du gemacht hast}. Erwartet: {X}. Passiert: {Y}.
Hier die Fehlermeldung:

{Fehlermeldung komplett einfügen}

Finde die Ursache, bevor du etwas änderst. Erkläre mir erst, WARUM es passiert.
Rate nicht, und probier nicht einfach etwas aus.
```

Der letzte Satz ist wichtig. Ohne ihn probieren LLMs gern drei Fixes hintereinander,
und am Ende weiß niemand mehr, was eigentlich kaputt war.

### Wenn dir etwas nicht gefällt

```
Der {Screen/Button/Flow} fühlt sich falsch an: {konkret beschreiben, was stört}.
Zeig mir zwei Alternativen mit Vor- und Nachteilen, bevor du etwas änderst.
```

---

## 3b. Kontext: der Chat ist kein Gedächtnis

Das Kontextfenster läuft in jeder längeren Session voll. Dagegen hilft kein Trick — aber
es ist auch nicht das Problem. Das Problem ist, den Chatverlauf als Speicher zu benutzen.

**Regel: Alles, was die nächste Session wissen muss, steht in einer Datei.**

### Die vier Speicherorte

| Ort | Was reinkommt | Wer pflegt |
|---|---|---|
| `CLAUDE.md` | Dauerhafte Projektregeln. **Max. 80 Zeilen** – wird jedes Mal geladen und kostet jedes Mal Kontext. | du, selten |
| `docs/02-IMPLEMENTATION-PLAN.md` | Fortschritt. Sonnet hakt `- [ ]` → `- [x]` ab. | Sonnet, nach jedem Task |
| `docs/DECISIONS.md` | Jede Abweichung vom Plan, jede Entscheidung, jeder Workaround – eine Zeile. | Sonnet, wenn es passiert |
| `git log` | Was wann gebaut wurde. | Sonnet, jeder Commit |

Wenn diese vier stimmen, ist der Chatverlauf **wegwerfbar**. Genau das ist das Ziel.

### `/clear` und `/compact` richtig einsetzen

| Situation | Befehl |
|---|---|
| Task fertig und committet | **`/clear`** – Verlauf weg, `CLAUDE.md` wird neu geladen. Der saubere Schnitt. |
| Mitten in einem Task, Kontext wird knapp | **`/compact`** – fasst zusammen und macht weiter. Verlustbehaftet, aber der Faden bleibt. |
| Kontext läuft von selbst voll | Passiert automatisch. Verlass dich nicht drauf – die automatische Zusammenfassung entscheidet selbst, was sie wegwirft. |

**Nach jedem Task `/clear`.** Nicht sparen. Eine frische Session, die den Plan neu liest,
ist besser als eine 200-Nachrichten-Session, die sich an das meiste falsch erinnert.

### Was Kontext frisst — und wie du es verhinderst

| Fresser | Gegenmittel |
|---|---|
| **Den 2.100-Zeilen-Plan komplett lesen** | Ab Session 2 nur den relevanten Teil: *"Lies in docs/02-IMPLEMENTATION-PLAN.md die Global Constraints und Meilenstein M3."* |
| **Lange Build- und Testausgaben** | *"Zeig mir nur die letzten 30 Zeilen"* bzw. `flutter test 2>&1 \| tail -30`. `build_runner` produziert hunderte Zeilen Rauschen. |
| **Große Dateien in den Chat pasten** | Nie. Sag den Pfad – Sonnet liest gezielt die Stellen, die es braucht. |
| **Screenshots** | Sparsam. Ein Screenshot kostet so viel wie mehrere hundert Zeilen Text. |
| **Suchen quer durchs Projekt** | Als Subagent: *"Nutze einen Subagent, um X zu finden, und gib mir nur das Ergebnis."* Die Suche läuft in eigenem Kontext, nur das Ergebnis kommt zurück. |
| **Ein zu langes `CLAUDE.md`** | Kurz halten. Es ist ein Wegweiser, keine Kopie des Plans. |

### Session-Start-Prompt ab Session 2

```
Wir sind bei Meilenstein M{X}, Tasks bis {X.Y} sind fertig und committet.

Lies in docs/02-IMPLEMENTATION-PLAN.md die "Global Constraints" und den
Abschnitt "Meilenstein M{X}". Den Rest des Plans brauchst du jetzt nicht.
Lies docs/DECISIONS.md.

Führe Task {X.Y+1} aus.
```

Das ist der ganze Zaubertrick: Sonnet zieht die Infos **aus den Dateien**, nicht aus dem
Chat. Dass es sie „jedes Mal neu zieht" ist kein Bug — es ist der Grund, warum die
Session 20 genauso zuverlässig ist wie Session 2.

### Am Ende jedes Tasks

```
Bevor du fertig bist:
1. Hake die erledigten Schritte in docs/02-IMPLEMENTATION-PLAN.md ab.
2. Trag in docs/DECISIONS.md ein, was du anders gemacht hast als im Plan
   und warum. Eine Zeile pro Punkt. Wenn nichts abwich: nichts eintragen.
3. Commit.
```

Danach `/clear`.

---

## 4. Was du selbst machen musst — das kann Sonnet nicht

| Aufgabe | Warum du |
|---|---|
| Flutter, Android Studio installieren | Braucht Downloads und Klicks auf deinem Rechner |
| Supabase-Projekt anlegen (Region Frankfurt!) | Account, Passwort, Zahlungsdaten |
| Apple Developer Account (99 $/Jahr) | Braucht deine Identität und Kreditkarte |
| Google Play Console (25 $ einmalig) | Dito |
| Firebase-Projekt für Push | Dito |
| **Auf echten Geräten testen** | Ein Emulator zeigt nicht, wie sich die App anfühlt |
| Schriftdateien herunterladen | Manuell von fonts.google.com |
| Anwalt für AGB/Datenschutz | Kein LLM ersetzt das |
| Beta-Tester aus der Community holen | Deine Kontakte, nicht seine |
| **Erste 50–100 Inserate einsammeln** | Ein leerer Marktplatz ist wertlos |

Der letzte Punkt ist der, an dem Marktplätze sterben. Die App kann perfekt sein — wenn
beim Start drei Inserate drin sind, kommt niemand ein zweites Mal. Sprich **jetzt schon**
mit befreundeten Teams: "Stellt eure nächsten Verkäufe zuerst bei uns ein."

---

## 5. Wie du reviewst, ohne Code zu können

Du musst kein Dart lesen. Aber diese fünf Dinge kannst du immer prüfen:

1. **Läuft es?** App starten, den Flow durchklicken, den du gerade gebaut hast.
2. **Sieht es aus wie im Design-System?** Farben, Abstände, Schrift — vergleiche mit
   `01-DESIGN-SYSTEM.md`.
3. **Was passiert bei schlechtem Netz?** Flugmodus an, Screen öffnen. Kommt eine
   Fehlermeldung mit Wiederholen-Button, oder dreht sich ein Spinner für immer?
4. **Was passiert bei leeren Daten?** Neues Konto, leere Favoriten, leerer Chat.
   Kommt ein hilfreicher leerer Zustand oder eine weiße Fläche?
5. **Lass dir die Testausgabe zeigen.** `flutter test` muss grün sein. Wenn Sonnet sagt
   "Tests laufen", frag: *"Zeig mir die Ausgabe."* — Behauptung ist nicht Beweis.

---

## 6. Typische Fallen bei der ersten App

| Falle | Gegenmittel |
|---|---|
| **Scope Creep.** "Können wir nicht noch schnell Bewertungen einbauen?" | Alles, was nicht in `00-SPEC.md` §3.1 steht, kommt auf eine Liste für v1.1. Ausnahmslos. |
| **Nur im Emulator testen.** Der Emulator hat schnelles Netz, viel RAM, keine echte Kamera. | Mindestens ein echtes Android-Gerät, ab M8 auch ein echtes iPhone. |
| **iOS erst am Ende anfassen.** | Ab M0 einmal pro Woche `flutter build ios --no-codesign` über CI laufen lassen. |
| **Keystore verlieren.** Ohne ihn kannst du deine Android-App nie wieder aktualisieren. | Keystore + Passwort in einen Passwortmanager, zusätzlich verschlüsselt in eine Cloud. |
| **Secrets ins Git committen.** | `.gitignore` prüfen, bevor der erste Commit rausgeht. Schlüssel, die einmal im Git-Verlauf sind, gelten als kompromittiert. |
| **Push-Notifications unterschätzen.** Auf iOS ist das ein eigener Nachmittag. | Puffer in M6 einplanen. |
| **App-Store-Review unterschätzen.** Eine Airsoft-App wird genauer angeschaut. | Review-Notizen laut `00-SPEC.md` §7.2 vorbereiten. Rechne mit 1–2 Ablehnungsrunden. |
| **Ohne Rechtstexte starten.** | Impressum, Datenschutz, AGB, Nutzungsbedingungen sind MVP, nicht "später". |

---

## 7. Reihenfolge, wenn ihr wenig Zeit habt

Falls sich zeigt, dass 13–16 Wochen zu lang sind: Diese Reihenfolge liefert nach jedem
Schritt etwas Vorzeigbares.

1. **M0 + M1** — ohne Fundament und Datenmodell geht gar nichts
2. **M2 + M3** — ab hier kann man die App herzeigen (stöbern, suchen)
3. **M4 + M5** — ab hier ist sie *benutzbar* (inserieren, ansehen)
4. **M6** — ab hier ist sie *nützlich* (Kontakt aufnehmen)
5. **M7 + M8** — ab hier ist sie *veröffentlichbar*

Nicht kürzbar: M7. Ohne Melden, Blockieren und Rechtstexte lehnt Apple die App ab.

---

## 8. Zwei Dinge, die ich anders machen würde, wenn ich ihr wäre

**Erstens: Baut den Chat früher als geplant, mit Fake-Daten.** Chat ist der Teil, der
technisch am meisten überrascht (Realtime, Push, iOS-Berechtigungen). Wenn ihr in Woche 10
merkt, dass Push auf iOS zickt, ist das schmerzhafter als in Woche 4. Ein Wegwerf-Prototyp
in M1 kostet zwei Tage und nimmt euch das größte Risiko.

**Zweitens: Redet mit ASVZ, bevor ihr startet.** Die haben die Community, ihr habt die App.
Eine Kooperation — und sei es nur ein Forenpost "es gibt jetzt eine App" — ist mehr wert
als jedes Feature, das ihr in der Zeit bauen könntet. Das Kaltstart-Problem ist bei
Marktplätzen die häufigste Todesursache, nicht schlechter Code.
