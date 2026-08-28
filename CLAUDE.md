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
