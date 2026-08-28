# ASM – Airsoft Marketplace

Flutter-App (iOS + Android) für den Handel mit gebrauchter Airsoft-Ausrüstung.
Backend: Supabase. State: Riverpod 2 mit Codegen. Routing: go_router.

## Vor jeder Aufgabe lesen
- `docs/02-IMPLEMENTATION-PLAN.md` – der verbindliche Plan. **Zuerst den Abschnitt
  "Stand" lesen** – dort steht, wo wir sind. Dann nur den aktuellen Meilenstein,
  nicht den ganzen Plan.
- `docs/DECISIONS.md` – Abweichungen und Stolpersteine aus früheren Sessions.
- `docs/01-DESIGN-SYSTEM.md` – Farben, Typografie, Komponenten. Nichts dazuerfinden.
- `docs/00-SPEC.md` – Produktentscheidungen, Kategorien, Rechtsanforderungen.
  Nur bei Bedarf, nicht routinemäßig.

## Am Ende jedes Tasks – immer, ohne Nachfrage
1. Abschnitt "Stand" in `docs/02-IMPLEMENTATION-PLAN.md` aktualisieren.
2. Abweichungen vom Plan in `docs/DECISIONS.md` eintragen (eine Zeile). Wenn nichts
   abwich: nichts eintragen.
3. Commit.

Der Chatverlauf ist wegwerfbar. Was die nächste Session wissen muss, steht in einer Datei.

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
