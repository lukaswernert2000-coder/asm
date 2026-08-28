# asm

Flutter-App (iOS + Android) für den Handel mit gebrauchter Airsoft-Ausrüstung.

## Starten

Secrets (Supabase-URL/Key, Sentry-DSN) kommen nie hartcodiert ins Repo, sondern über
`--dart-define-from-file`. Vor dem ersten Start `env/example.json` nach `env/dev.json`
kopieren und mit echten Werten füllen (Datei ist gitignored):

```bash
flutter run --dart-define-from-file=env/dev.json
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
