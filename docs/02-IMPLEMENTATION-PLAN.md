# ASM – Airsoft Marketplace · Implementierungsplan

> **Für Sonnet:** Arbeite diesen Plan **Meilenstein für Meilenstein, Task für Task** ab.
> Beginne jeden Task mit dem Test, dann die Implementierung, dann `flutter analyze`,
> dann Commit. Hake `- [ ]` zu `- [x]` ab, sobald ein Task fertig **und** verifiziert ist.
> Springe nicht vor. Wenn dir Information fehlt, lies zuerst `00-SPEC.md` und
> `01-DESIGN-SYSTEM.md` – dort steht fast alles.

**Ziel:** Eine produktionsreife Flutter-App für iOS und Android, mit der Airsoft-Spieler
gebrauchte Ausrüstung inserieren, finden und per Chat verhandeln können.

**Architektur:** Feature-first Flutter-Client (Riverpod + go_router) auf einem
Supabase-Backend (Postgres, Auth, Storage, Realtime). Alle Zugriffsrechte werden in
Postgres über Row-Level-Security durchgesetzt; der Client hat keine privilegierten Keys.
Suche und Filter laufen über eine einzige Postgres-Funktion, nicht über zusammengebaute
Client-Queries.

**Tech-Stack:** Flutter · Dart · Riverpod 2 · go_router · freezed · Supabase ·
Firebase Cloud Messaging · Sentry

**Spec:** [`00-SPEC.md`](00-SPEC.md) · **Design:** [`01-DESIGN-SYSTEM.md`](01-DESIGN-SYSTEM.md)

> **Zur Detailtiefe dieses Plans:** M0 und M1 sind bis auf Code-Ebene ausgeschrieben —
> das sind die Teile, bei denen ein Fehler später alles infiziert (Theme, Datenmodell,
> Sicherheitsregeln). Ab M2 sind die Tasks auf Ebene *Dateien, Schnittstellen,
> Akzeptanzkriterien* spezifiziert. Sonnet schreibt dort den Code gegen diese Vorgaben.
> **Wenn ein Task ab M2 ansteht, zerlege ihn zuerst selbst in TDD-Schritte
> (Test → rot → Implementierung → grün → Commit) und zeig die Liste, bevor du anfängst.**

---

## 📍 Stand

> **Diese Zeilen sind die einzige Wahrheit über den Fortschritt.** Sonnet aktualisiert sie
> als letzten Schritt jedes Tasks — vor dem Commit. Wer wissen will, wo das Projekt steht,
> liest hier, nicht im Chatverlauf.

| | |
|---|---|
| **Meilenstein** | M3 · Kategorien, Feed und Suche |
| **Fertig** | M0 komplett (Task 0.1–0.8) · M1 komplett (Task 1.1–1.9) · M2 komplett (Task 2.1–2.7, Code-seitig — offene Verifikationen siehe unten) · Task 8.0 Teil A Schritt 1–6 (Code fertig, siehe unten) · Task 3.1 komplett (Code-seitig, siehe unten — nicht live verifiziert) · Task 3.2 komplett (Code-seitig, siehe unten — nicht live verifiziert) |
| **Als Nächstes** | **Task 3.3 — Suche** |
| **Offen in M0** | keins — eine Einschränkung, siehe unten |
| **Letzter Commit** | `feat(listings): add paginated feed with pull to refresh` |
| **Stand vom** | 2026-08-30 |

Repo ist auf GitHub (`lukaswernert2000-coder/asm`). **Task 2.1–2.4 sind jetzt gepusht**
(Nutzer hat dem Push zugestimmt, Außer-der-Reihe-Punkt B) — CI lief danach zum ersten Mal
wirklich über den vollständigen M1+M2-Code (vorher liefen nur M0/Doku-Pushes durch) und war
grün ([Run #4](https://github.com/lukaswernert2000-coder/asm/actions/runs/33254178642),
`conclusion: success`). Der Task-8.0A-Push ist ebenfalls gepusht und CI-grün
([Run #5](https://github.com/lukaswernert2000-coder/asm/actions/runs/33255167140),
`conclusion: success`). **Task 8.0 Teil A (Schritte 1–6, 9):** vier Rechtstexte
(`assets/legal/*.md`, Entwürfe mit Platzhaltern für Impressum-Pflichtangaben),
`tool/gen_website.dart`, `website/style.css`, `index.html`, `account-loeschen.html` —
lokal per `npx serve` geprüft. **Schritte 7–8 (Postfach anlegen, Hochladen zu Hostinger)
kann Sonnet nicht ausführen** und bleiben offen für den Nutzer, sind aber unabhängig vom
App-Code — blockieren Task 2.5 nicht. Details und Abwägungen in DECISIONS.md. **Task 2.5:**
`ProfileScreen`, `EditProfileScreen`, `PublicProfileScreen`, `MyListingsScreen` neu, dazu
`moderation`-Feature (Melden/Blockieren, echte Aktion) und `guards.dart` um `/settings`
erweitert. Zwei echte, vorher unbemerkte Layout-Bugs bei 400 px Breite gefunden und
behoben (`LoginScreen`, `PublicProfileScreen`), Details in DECISIONS.md. **Nicht live auf
dem Emulator verifiziert** — die Registrierung eines Testkontos scheiterte am
Geburtsdatum-Datepicker (`adb`-Taps unzuverlässig, wie schon in der Task-2.4-Session),
verlässt sich auf die 160 grünen Tests. Task-2.5-Push ist CI-grün
([Run #6](https://github.com/lukaswernert2000-coder/asm/actions/runs/33258058007),
`conclusion: success`). Task 2.2–2.4
liefen (jeweils zumindest teilweise) auf dem Android-**Emulator** gegen das echte
Dev-Supabase-Projekt durch, siehe DECISIONS.md — das ist aber weiterhin **kein Test auf
echter Hardware**. Bleibt offen wie schon seit M0: kein Test auf einem echten Android- oder
iOS-Gerät. Weiterhin offen seit Task 2.3: der **echte E-Mail-Link-Tap für
`asm://auth-callback`/`asm://reset-password`** wurde nicht durchgespielt (Supabase-E-Mail-
Limit in dieser Session ausgeschöpft) — bei Bedarf mit einer echten/mailinator-Adresse
nachholen, siehe DECISIONS.md. Zusätzlich: das Supabase-Projekt-Limit
`auth.rate_limit.email_sent = 2`/Stunde ist beim manuellen Testen sehr schnell erreicht —
künftige Sessions sollten E-Mail-auslösende Aktionen (Registrieren, Erneut senden,
Passwort vergessen) sparsam einsetzen und wissen, dass "email rate limit exceeded" kein
Bug ist. Neu offen seit Task 2.4: das Altersgate (`blocksForAge` in `guards.dart`) ist
fertig und getestet, aber an keine Route angebunden — `/category/:slug` kommt erst in M3;
und ob "eingeloggt, aber E-Mail unbestätigt" (`/create`-Hinweis-Regel) über einen normalen
Login je erreichbar ist, wurde nicht live geprüft. Beides mit Details in DECISIONS.md.
**Task 2.6:** `delete-account`-Edge-Function (erste Function im Projekt, `@supabase/server`
mit `auth: "user"`), `DeleteAccountScreen` mit Bestätigungsdialog (Nutzername eintippen),
neue Menüzeile in `ProfileScreen`, `error_mapper.dart` um `FunctionException` erweitert.
Alle Dart-Tests grün (168), `flutter analyze` 0 Probleme. Die Webseite
`account-loeschen.html` aus Task 8.0 erfüllt die Google-Play-Pflicht bereits, ein
veralteter Navigationspfad darin wurde korrigiert. Edge Function ist **deployt**
(`xlpgrexkiigzqrcmkenv`, nach Nutzer-Freigabe — erster Versuch vom Auto-Mode-Classifier
blockiert). **Inzwischen voll live verifiziert** (siehe M2-Komplettflow-Eintrag unten):
Löschen + anschließender Login-Fehlversuch funktioniert wie im Plan gefordert.

**2026-08-29, M2-Komplettflow live durchgespielt:** Auf Nutzerwunsch den gesamten
M2-Abschlusskriterium-Flow einmal echt durchgeklickt (Erststart → Onboarding →
Registrieren → E-Mail bestätigen → einloggen → Profil ausfüllen → abmelden → wieder
einloggen → Account löschen → Login schlägt danach fehl) — **alles bestätigt**, bis auf
den expliziten "echtes Gerät statt Emulator"-Teil, der laut `03-ARBEITEN-MIT-SONNET.md`
Abschnitt 4 Nutzer-Aufgabe ist. Dabei einen **echten, vorher unbemerkten Bug gefunden und
behoben**: `SupabaseProfileRepository.byId()` nutzte ein spaltenloses `select()` (=
`select(*)`), das gegen die spaltenbeschränkten Grants aus `0001_profiles.sql` für
**jeden** Nutzer mit `42501` fehlschlug (kein Test konnte das fangen, da alle
Profil-Tests nur gegen ein gemocktes Repository-Interface laufen). Fix: explizite
Spaltenliste passend zum Grant. Volle Details, inklusive der Deep-Link-Besonderheit
(E-Mail-Bestätigungslink muss im **emulator-eigenen** Browser angetippt werden, nicht im
Host-Browser) in DECISIONS.md.
Fällt mit der ohnehin offenen "kein Test auf echtem Gerät"-Zeile zusammen, die M2 laut
Abschlusskriterium unten sowieso noch braucht. Details zur bewusst ausgesparten
`chat-images`-Bereinigung ebenfalls in DECISIONS.md. Task-2.6-Push ist CI-grün
([Run #7](https://github.com/lukaswernert2000-coder/asm/actions/runs/33266628565),
`conclusion: success`).
**Task 2.7:** `SplashScreen` (reiner Wartebildschirm, Logik sitzt in `AsmApp`),
`OnboardingScreen` (3 Seiten, Punktindikator, "Überspringen"/"Fertig"),
`WelcomeScreen`, dazu zwei vorher fehlende Bausteine nachgezogen:
`rootCategoriesProvider`/`categoryRepositoryProvider` (Task 1.9 hatte nur das
Repository, keinen Provider) und `sharedPreferencesProvider` (neue
`SharedPreferencesWithCache`-API statt der veralteten `getInstance()`-Variante).
Onboarding-Gate sitzt in `guards.dart` (`/` → `/onboarding` beim allerersten Start),
nicht als eigene GoRoute für Splash. **Logo ist ein Platzhalter** ("ASM" als Text) —
Nutzer liefert das echte Logo erst am Ende des Milestones nach, siehe DECISIONS.md.
Alle Tests grün (174), `flutter analyze` 0 Probleme. `flutter_native_splash` konfiguriert
und generiert (nur Hintergrundfarbe, kein Bild). **Live auf dem Emulator bestätigt:**
kompletter Flow Splash → Onboarding (alle 3 Seiten) → Willkommen → Gast-Feed, UND das
Skip-Verhalten beim zweiten Start (Onboarding-Flag gesetzt → direkt zum Start-Tab) — Details
und eine Beobachtung zum nativen Splash-Icon (faellt mangels eigenem App-Icon auf
Flutter-Default zurueck, siehe Task 8.2) in DECISIONS.md.

**2026-08-30, Task 3.1:** `CategoryTile` (`lib/features/categories/presentation/widgets/`)
und `ListingCard` (`lib/features/listings/presentation/widgets/`, Varianten `.grid`/`.list`)
neu gebaut — beide existierten vorher nur als Spec in `01-DESIGN-SYSTEM.md`. Dazu zwei neue
Provider (`categoryBySlugProvider`, `categoryChildrenProvider`) und ein bewusst schlanker
`categoryFeedProvider` (einmaliger `search()`-Aufruf ohne Pagination — Task 3.2 ersetzt ihn
durch den echten `listingFeedProvider`). `CategoryOverviewScreen` ersetzt den
`_BranchPlaceholder` auf der Start-Route, `CategoryScreen` ist neu unter `/category/:slug`
verdrahtet (Unterkategorien-Chips + gefilterter Feed). `/listing/:id` bekommt vorerst
denselben Platzhalter-Screen wie Favoriten/Einstellungen, damit ein Kartentipp nicht ins
Leere läuft — echte Detailseite ist M4. Die 8 Kategorie-Icons plus `f-marking.svg` wurden
als handgezeichnete, einfache Linien-SVGs angelegt (`assets/icons/categories/*.svg`, vorher
nur `.gitkeep`) — kein Profi-Set, bei Bedarf austauschbar. **Altersgate bewusst nicht
verdrahtet:** Nutzer hat auf Nachfrage klargestellt, dass Kategorien und Inserate für
**alle** (Gast, Minderjährig, Erwachsen) ansehbar bleiben sollen — nur eine künftige
Kauf-/Kontaktieren-Aktion wird für nicht-volljährige bzw. nicht eingeloggte Nutzer gesperrt.
Dabei aufgefallen: Die RLS-Policy aus Task 1.4 blockt `requires_age_18`-Zeilen aktuell
komplett auf SELECT-Ebene — das widerspricht dieser Absicht und ist noch nicht aufgelöst,
Details in DECISIONS.md. `blocksForAge()` bleibt unverändert fertig/getestet, aber unwired.
**Nicht live auf Emulator/Gerät verifiziert** — 194 Tests grün, `flutter analyze`
0 Probleme, verlässt sich wie schon bei Task 2.5 auf die Testsuite; das Projekt hat bewusst
keine Web-Plattform (nur Android/iOS seit Task 0.1), ein schneller Browser-Check war deshalb
nicht möglich. Task-3.1-Push ist CI-grün, erst nach einem Formatierungs-Fix
([Run #14](https://github.com/lukaswernert2000-coder/asm/actions/runs/33278330235) rot an
`dart format --set-exit-if-changed .`, [Run #15](https://github.com/lukaswernert2000-coder/asm/actions/runs/33278516881)
`conclusion: success`).

**2026-08-30, Task 3.2:** `listingFeedProvider(ListingFilter)` als `FamilyAsyncNotifier`
(`listing_feed_controller.dart`, kein Codegen — Projekt-Konvention seit Task 1.9) mit
`loadMore()`/`refresh()`, State ist ein anonymes Record `{items, total, isLoadingMore}`.
`CategoryScreen`s Haupt-Feed nutzt jetzt `listingFeedProvider` statt des schlanken
Task-3.1-`categoryFeedProvider` — Letzterer bleibt für "Neu eingestellt" auf der Startseite
bestehen (keine Pagination nötig dort). Nachladen bei 80 % Scrolltiefe (`ScrollController`),
Pull-to-Refresh (`RefreshIndicator`), dabei hängen Shimmer-Platzhalter ans Ende der Liste
statt den ganzen Screen zu ersetzen — dafür `AsmSkeleton` um eine vierte Variante `.card`
ergänzt (eine einzelne Shimmer-Karte, rein additiv, ändert nichts an den drei bestehenden
Layouts). Grid-/Listen-Umschalter als Icon-Button in der `CategoryScreen`-AppBar,
Präferenz in `shared_preferences` (`listingViewModeProvider`/`setListingViewMode()`, exakt
das Muster von `hasSeenOnboardingProvider`/`markOnboardingSeen()` aus Task 2.7 kopiert) —
dafür musste der neue Key in `main.dart`s und `fake_shared_preferences.dart`s
`SharedPreferencesWithCache`-Allowlist ergänzt werden, sonst würde er still verworfen.
`dart format lib test` diesmal **vor** dem Push gelaufen (Lehre aus Task 3.1, wo das erst
CI rot laufen ließ). 30 neue Tests, davon einer mit echtem Scroll-/Fling-Gesten-Test für
Nachladen und Pull-to-Refresh (kein Mock der Scroll-Mechanik) — lief beim ersten Versuch
durch. **Nicht live auf Emulator/Gerät verifiziert**, gleicher Grund wie Task 3.1 (keine
Web-Plattform). 206 Tests grün, `flutter analyze` 0 Probleme.

Bekannte Stolpersteine aus bisherigen Sessions stehen in [`DECISIONS.md`](DECISIONS.md).

### 🔁 Außer der Reihe — vor Task 2.5 abarbeiten

Drei Dinge, die nicht am Meilenstein-Faden hängen, aber jetzt fällig sind. Reihenfolge
einhalten – jeder Schritt setzt den vorigen voraus.

| # | Was | Warum jetzt |
|---|---|---|
| **A** | Task 2.4 fertigstellen und committen | Nicht mittendrin abbiegen – die Arbeitskopie ist offen |
| **B** | Die dann ~9 ungepushten Commits pushen | M2 existiert nur lokal. `gh` ist nicht installiert, normales `git push` benutzen |
| **C** | CI grün bekommen | Läuft mit dem Push zum ersten Mal über M1 und M2. Vorher bestätigt grün war nur M0 |
| **D** | [Task 8.0 Teil A](#task-80-website-und-rechtsseiten) – Website und Rechtstexte | Hängt an keinem App-Code, liefert die Markdown-Quelle für Task 7.2, und die Store-URLs müssen vor der Einreichung stehen |

Danach normal weiter mit Task 2.5.

---

## Global Constraints

Diese Regeln gelten für **jeden** Task. Sie werden nicht wiederholt.

| # | Regel |
|---|---|
| G1 | Flutter **stable channel**, Dart 3.x. Die tatsächlich verwendete Version wird in M0 in `docs/TOOLCHAIN.md` festgehalten. `pubspec.lock` wird committet. |
| G2 | Ziel-Plattformen: **iOS 14+**, **Android API 26+**. `minSdkVersion 26` in `android/app/build.gradle`. |
| G3 | Sprache der App: **nur Deutsch** (`de_DE`). Alle sichtbaren Strings kommen aus `l10n/app_de.arb`, keine hartcodierten Strings in Widgets. |
| G4 | **Nur Dark-Theme.** `MaterialApp.theme = AsmTheme.dark`, `darkTheme` identisch, `themeMode: ThemeMode.dark`. |
| G5 | **Keine Farb-, Größen- oder Abstands-Literale in Widgets.** Alles aus `AsmColors`, `AsmSpacing`, `AsmRadius`, `AsmTextStyles`. |
| G6 | Supabase-Projekt liegt in Region **eu-central-1 (Frankfurt)**. |
| G7 | In der App wird **ausschließlich der `anon`-Key** verwendet. Der `service_role`-Key kommt niemals in Client-Code, nicht in `.env`, nicht ins Repo. |
| G8 | **Jede** Tabelle in `public` hat `enable row level security` und mindestens eine Policy. Eine Tabelle ohne Policy ist ein Bug. |
| G9 | `flutter analyze` muss 0 Fehler **und** 0 Warnungen melden, bevor committet wird. |
| G10 | Commit-Format: [Conventional Commits](https://www.conventionalcommits.org) – `feat:`, `fix:`, `test:`, `chore:`, `docs:`, `refactor:`. |
| G11 | Geheimnisse (Supabase-URL/Key, Sentry-DSN) kommen über `--dart-define-from-file=env/dev.json`. `env/` steht in `.gitignore`, `env/example.json` wird committet. |
| G12 | **Kein `google_fonts` mit Runtime-Download** (DSGVO). Schriften als Asset bündeln. |
| G13 | Kein Widget beschafft eigene Daten. Daten kommen über Riverpod-Provider; Widgets bekommen sie als Parameter oder über `ref.watch`. |
| G14 | Jede Netzwerkoperation hat drei sichtbare Zustände: Laden (Skeleton), Fehler (mit Retry), Erfolg. Kein Endlos-Spinner. |
| G15 | Jeder Icon-Button hat ein `Semantics`-Label. Jedes Tap-Ziel ist mindestens 48×48 dp. |

---

## Architektur-Entscheidungen (ADRs)

| ID | Entscheidung | Alternative | Warum so |
|---|---|---|---|
| ADR-1 | **Supabase** als Backend | Firebase | Der Feed braucht `WHERE preis BETWEEN … AND kategorie IN … AND joule < … ORDER BY entfernung`. In Postgres ist das eine Zeile, in Firestore braucht es für jede Filterkombination einen eigenen Composite-Index und scheitert an Bereichsfiltern auf mehreren Feldern. Dazu: RLS ist echte Sicherheit auf DB-Ebene, Volltextsuche ist eingebaut, EU-Region wählbar. |
| ADR-2 | **Riverpod 2 mit Codegen** | BLoC, Provider | Weniger Boilerplate als BLoC, compile-time-sicher, `AsyncValue` deckt Laden/Fehler/Daten out of the box ab, exzellent unit-testbar ohne Widget-Tests. |
| ADR-3 | **go_router** | Navigator 2.0 direkt | Deep Links (`asm://listing/<id>`) sind für einen Marktplatz Pflicht (Teilen-Funktion), und Auth-Redirects sind deklarativ lösbar. |
| ADR-4 | **Eine Postgres-RPC für die Suche** | Query-Builder im Client | Die Filterlogik existiert einmal, ist in SQL testbar, und der Client kann keine ungültigen Kombinationen bauen. Verhindert außerdem N+1-Queries für Bilder und Verkäuferdaten. |
| ADR-5 | **Keine GPS-Berechtigung, PLZ-basiert** | `geolocator` | Spart den Berechtigungsdialog, das Store-Formular zur Standortnutzung und DSGVO-Aufwand. PLZ-Genauigkeit reicht für "12 km entfernt" völlig. Ein gebündelter PLZ-Datensatz (~8.200 Zeilen) macht das offline möglich. |
| ADR-6 | **FCM für Push** | Supabase-eigene Lösung | Es gibt keine. Für iOS ist APNs Pflicht, FCM ist der einzige praktikable Weg, beide Plattformen mit einer Codebasis zu bedienen. |
| ADR-7 | **Kein Social Login im MVP** | Apple/Google Sign-In | Apple erzwingt "Sign in with Apple" nur, wenn ein anderer Drittanbieter-Login existiert. Ohne Social Login entfällt diese Pflicht komplett – spart im MVP mehrere Tage. |
| ADR-8 | **Keine Zahlungsabwicklung** | Treuhand/Stripe | Sobald Geld über die Plattform fließt, greifen Zahlungsdiensteaufsicht (ZAG), Geldwäschegesetz und Plattform-Meldepflichten. Das ist ein eigenes Projekt, kein MVP-Feature. |

---

## Ordnerstruktur

Diese Struktur wird in M0 angelegt und danach nicht mehr umgebaut.

```
ASM-Airsoft-Marketplace/          <- Repo-Wurzel, hier liegt CLAUDE.md
├── android/ · ios/
├── assets/
│   ├── fonts/            Inter-*.ttf, BarlowCondensed-*.ttf
│   ├── icons/
│   │   ├── categories/   8 Kategorie-SVGs
│   │   ├── f-marking.svg
│   │   └── logo.svg
│   ├── images/           Onboarding-Illustrationen, Platzhalter
│   └── data/plz.json     PLZ → {ort, lat, lng}
├── env/
│   ├── example.json      committed
│   ├── dev.json          gitignored
│   └── prod.json         gitignored
├── lib/
│   ├── main.dart                    Bootstrap, Sentry, Supabase-Init
│   ├── app.dart                     MaterialApp.router
│   ├── core/
│   │   ├── theme/                   asm_colors, asm_spacing, asm_text_styles, asm_theme
│   │   ├── router/                  app_router.dart, routes.dart, guards.dart
│   │   ├── supabase/                supabase_provider.dart
│   │   ├── errors/                  app_exception.dart, error_mapper.dart
│   │   ├── utils/                   formatters.dart, validators.dart, plz_lookup.dart
│   │   └── widgets/                 asm_button, asm_text_field, asm_chip,
│   │                                asm_empty_state, asm_skeleton, asm_scaffold,
│   │                                asm_network_image, asm_error_view
│   ├── features/
│   │   ├── auth/        {data,domain,presentation}
│   │   ├── categories/  {data,domain,presentation}
│   │   ├── listings/    {data,domain,presentation}
│   │   ├── search/      {data,domain,presentation}
│   │   ├── favorites/   {data,domain,presentation}
│   │   ├── chat/        {data,domain,presentation}
│   │   ├── profile/     {data,domain,presentation}
│   │   ├── moderation/  {data,domain,presentation}
│   │   └── legal/       presentation
│   └── l10n/            app_de.arb, generated
├── supabase/
│   ├── migrations/      0001_*.sql … 
│   ├── seed/            categories.sql
│   └── functions/       notify-on-message/
├── test/                Spiegel von lib/
├── integration_test/    app_test.dart
└── docs/                diese Dateien
```

**Konvention je Feature:**
- `data/` – `*_repository.dart` (Supabase-Zugriff), `*_dto.dart`
- `domain/` – freezed-Modelle, reine Logik
- `presentation/` – `*_screen.dart`, `widgets/`, `*_controller.dart` (Riverpod)

---

# Meilenstein M0 · Fundament

**Ergebnis:** Eine leere, aber lauffähige App mit korrektem Theme, Navigation, Linting
und CI. Auf einem echten Android-Gerät gestartet.

---

## ⚠️ Task 0.0: Toolchain – das musst du selbst wissen

**Aktueller Stand auf diesem Rechner (geprüft 2026-08-28): Flutter, Dart und Node sind
nicht installiert. Nur Git und Java sind vorhanden.**

### Was installiert werden muss (Windows)

- [ ] **Flutter SDK** (stable) → <https://docs.flutter.dev/get-started/install/windows>
      Nach `C:\src\flutter` entpacken, `C:\src\flutter\bin` in die PATH-Variable.
      **Nicht** in einen Ordner mit Leerzeichen oder Umlauten legen.
- [ ] **Android Studio** (inkl. Android SDK, Platform-Tools, ein Emulator-Image API 34)
- [ ] **Git** – bereits vorhanden ✅
- [ ] **VS Code** + Extensions "Flutter" und "Dart" (oder Android Studio direkt)
- [ ] Prüfen mit:

```bash
flutter doctor -v
```

Alle Häkchen außer den iOS-Zeilen müssen grün sein. `flutter doctor --android-licenses`
einmal ausführen und alle Lizenzen akzeptieren.

### 🚨 iOS-Builds gehen auf Windows nicht

Für iOS-Builds ist zwingend macOS mit Xcode nötig. Das ist eine harte Apple-Beschränkung,
kein Flutter-Problem. Drei gangbare Wege:

| Weg | Kosten | Bewertung |
|---|---|---|
| **Cloud-CI (Codemagic)** – iOS-Build und TestFlight-Upload laufen auf gemieteten Mac-Runnern | Gratis-Kontingent, danach ca. 0,10 €/Min | **Empfohlen für den Start.** Android lokal entwickeln, iOS über CI bauen. Nachteil: kein iOS-Simulator zum Debuggen. |
| **Gebrauchter Mac mini (M1)** | ca. 400–600 € | Beste Lösung, sobald es ernst wird. Spätestens vor M8 nötig. |
| **MacInCloud / Mac-Miete** | ca. 25–30 €/Monat | Zwischenlösung, umständlich |

Dazu kommen unvermeidbar:
- **Apple Developer Program: 99 USD/Jahr** – ohne das kein TestFlight und kein App Store
- **Google Play Developer: 25 USD einmalig**

**Plan-Empfehlung:** M0–M7 komplett auf Android entwickeln und testen. iOS-Setup und
erster iOS-Build in **M8**. Bis dahin regelmäßig `flutter build ios --no-codesign`
über die CI laufen lassen, damit Plattformprobleme früh auffallen und nicht erst am Ende.

---

## Task 0.1: Projekt anlegen

**Dateien:** gesamtes Projektgerüst

- [ ] **Schritt 1: Projekt erzeugen — im vorhandenen Ordner, nicht in einem Unterordner**

Der Ordner `ASM-Airsoft-Marketplace/` mit `docs/` existiert bereits. Das Flutter-Projekt
wird **direkt darin** erzeugt, damit `docs/` Teil des Repos ist und die relativen Pfade
in `CLAUDE.md` stimmen. Führe den Befehl **innerhalb** von `ASM-Airsoft-Marketplace/` aus:

```bash
flutter create --org de.asmapp --project-name asm --platforms=android,ios .
```

Der Punkt am Ende ist wichtig. `flutter create` in einen nicht-leeren Ordner ist
unproblematisch – bestehende Dateien werden nicht angefasst.

Zielstruktur danach:

```
ASM-Airsoft-Marketplace/     <- Repo-Wurzel
├── CLAUDE.md                <- kommt in Schritt 4
├── docs/                    <- die vier Planungsdokumente
├── lib/  android/  ios/  test/
└── pubspec.yaml
```

- [ ] **Schritt 2: Toolchain dokumentieren**

`flutter --version` ausführen und die Ausgabe in `docs/TOOLCHAIN.md` festhalten
(Flutter-Version, Dart-Version, Datum). Alle späteren Tasks gehen von genau dieser Version aus.

- [ ] **Schritt 3: Git initialisieren**

```bash
git init && git add -A && git commit -m "chore: flutter project scaffold"
```

- [ ] **Schritt 4: `.gitignore` erweitern**

Ergänze: `env/*.json`, `!env/example.json`, `*.jks`, `key.properties`,
`ios/Runner/GoogleService-Info.plist`, `android/app/google-services.json`,
`.env`, `coverage/`

- [ ] **Schritt 5: `minSdkVersion` auf 26 setzen**

In `android/app/build.gradle.kts`: `minSdk = 26`.

- [ ] **Schritt 6: App auf einem echten Gerät starten**

```bash
flutter devices
flutter run
```

**Akzeptanz:** Die Counter-Demo-App läuft auf einem echten Android-Gerät oder Emulator.

- [ ] **Schritt 7: Commit** — `chore: configure android min sdk and gitignore`

---

## Task 0.2: Abhängigkeiten

**Dateien:** `pubspec.yaml`

- [ ] **Schritt 1: Pakete hinzufügen**

```bash
flutter pub add flutter_riverpod riverpod_annotation go_router supabase_flutter \
  freezed_annotation json_annotation cached_network_image image_picker \
  flutter_image_compress shared_preferences flutter_secure_storage intl \
  flutter_svg lucide_icons_flutter shimmer share_plus url_launcher \
  package_info_plus sentry_flutter connectivity_plus collection

flutter pub add --dev build_runner riverpod_generator freezed json_serializable \
  custom_lint riverpod_lint very_good_analysis mocktail \
  flutter_launcher_icons flutter_native_splash

flutter pub add flutter_localizations --sdk=flutter
```

> Firebase-Pakete (`firebase_core`, `firebase_messaging`, `flutter_local_notifications`)
> kommen erst in **M6**. Vorher nicht hinzufügen – sie machen den Build langsamer und
> erzwingen Plattform-Konfiguration, die noch nicht gebraucht wird.

- [ ] **Schritt 2: Codegen-Skript anlegen**

In `Makefile` bzw. `tool/gen.sh`:
`dart run build_runner build --delete-conflicting-outputs`

- [ ] **Schritt 3: `flutter analyze`** → 0 Issues
- [ ] **Schritt 4: Commit** — `chore: add core dependencies`

---

## Task 0.3: Linting und Analyse

**Dateien:** `analysis_options.yaml`

- [ ] **Schritt 1: Konfiguration schreiben**

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  plugins:
    - custom_lint
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "lib/l10n/generated/**"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    public_member_api_docs: false      # zu streng fuer App-Code
    lines_longer_than_80_chars: false  # 100 ist unser Limit
    prefer_single_quotes: true
    always_use_package_imports: true
    avoid_print: true
```

- [ ] **Schritt 2: `flutter analyze`** → 0 Issues (Demo-Code aus `main.dart` ggf. aufräumen)
- [ ] **Schritt 3: Commit** — `chore: configure very_good_analysis linting`

---

## Task 0.4: Design-System-Code

**Dateien:**
- Create: `lib/core/theme/asm_colors.dart`, `asm_spacing.dart`, `asm_text_styles.dart`, `asm_theme.dart`
- Create: `assets/fonts/` (Inter 400/500/600/700, BarlowCondensed 600/700 als `.ttf`)
- Modify: `pubspec.yaml`
- Test: `test/core/theme/asm_theme_test.dart`

**Produziert:** `AsmColors`, `AsmSpacing`, `AsmRadius`, `AsmDuration`, `AsmTextStyles`, `AsmTheme.dark`
— wird von **allen** späteren Tasks verwendet.

- [ ] **Schritt 1: Schriften besorgen und einbinden**

Inter und Barlow Condensed von <https://fonts.google.com> als ZIP herunterladen
(**nicht** über das `google_fonts`-Paket, siehe G12), die benötigten Schnitte nach
`assets/fonts/` kopieren und in `pubspec.yaml` deklarieren:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/icons/categories/
    - assets/images/
    - assets/data/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
    - family: BarlowCondensed
      fonts:
        - asset: assets/fonts/BarlowCondensed-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/BarlowCondensed-Bold.ttf
          weight: 700
```

- [ ] **Schritt 2: Failing Test schreiben**

```dart
// test/core/theme/asm_theme_test.dart
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsmTheme.dark', () {
    final theme = AsmTheme.dark;

    test('nutzt den Tactical-Olive Hintergrund', () {
      expect(theme.scaffoldBackgroundColor, AsmColors.bg);
    });

    test('ist ein Dark-Theme', () {
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('nutzt brandBright als Primaerfarbe', () {
      expect(theme.colorScheme.primary, AsmColors.brandBright);
      expect(theme.colorScheme.onPrimary, AsmColors.onBrand);
    });

    test('nutzt Inter als Standardschrift', () {
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
    });

    test('AppBar ist flach und ohne Tint', () {
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
    });
  });
}
```

- [ ] **Schritt 3: Test laufen lassen** — `flutter test test/core/theme/` → **FAIL** (Dateien fehlen)

- [ ] **Schritt 4: Die vier Theme-Dateien anlegen**

Vollständiger Code steht in [`01-DESIGN-SYSTEM.md`, Abschnitt 8](01-DESIGN-SYSTEM.md#8-fertiger-themedart).
**Übernimm ihn wörtlich.**

- [ ] **Schritt 5: Test laufen lassen** → **PASS**

- [ ] **Schritt 6: `main.dart` und `app.dart` auf das Theme umstellen**

```dart
// lib/app.dart
import 'package:asm/core/theme/asm_theme.dart';
import 'package:flutter/material.dart';

class AsmApp extends StatelessWidget {
  const AsmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASM',
      debugShowCheckedModeBanner: false,
      theme: AsmTheme.dark,
      darkTheme: AsmTheme.dark,
      themeMode: ThemeMode.dark,
      home: const Scaffold(body: Center(child: Text('ASM'))),
    );
  }
}
```

- [ ] **Schritt 7: Optisch prüfen** — App starten, Hintergrund ist `#171A18`, Text ist `#E8EAE5`
- [ ] **Schritt 8: Commit** — `feat(theme): add tactical olive design tokens and theme`

---

## Task 0.5: Kern-Widgets

**Dateien:**
- Create: `lib/core/widgets/asm_button.dart`, `asm_text_field.dart`, `asm_chip.dart`,
  `asm_empty_state.dart`, `asm_skeleton.dart`, `asm_error_view.dart`, `asm_network_image.dart`
- Test: `test/core/widgets/asm_button_test.dart`, `asm_chip_test.dart`

**Produziert:** `AsmButton({required String label, VoidCallback? onPressed, AsmButtonVariant variant, bool isLoading, IconData? icon})`,
`AsmTextField`, `AsmChip({required String label, required bool selected, VoidCallback? onTap, IconData? icon})`,
`AsmEmptyState({required IconData icon, required String title, String? message, Widget? action})`,
`AsmSkeleton.listingGrid() / .listingList() / .detail()`,
`AsmErrorView({required String message, required VoidCallback onRetry})`,
`AsmNetworkImage({required String? path, double? aspectRatio, BorderRadius? radius})`

Spezifikationen: [`01-DESIGN-SYSTEM.md` Abschnitt 5](01-DESIGN-SYSTEM.md#5-komponenten-spezifikationen).

- [ ] **Schritt 1: Failing Tests für `AsmButton`**

```dart
// test/core/widgets/asm_button_test.dart
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('primary rendert Label auf brandBright', (tester) async {
    await tester.pumpWidget(_wrap(
      AsmButton(label: 'Inserat aufgeben', onPressed: () {}),
    ));
    expect(find.text('Inserat aufgeben'), findsOneWidget);

    final container = tester.widget<Container>(
      find.descendant(of: find.byType(AsmButton), matching: find.byType(Container)).first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AsmColors.brandBright);
  });

  testWidgets('isLoading blendet das Label aus und zeigt einen Spinner',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const AsmButton(label: 'Speichern', isLoading: true),
    ));
    expect(find.text('Speichern'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('onPressed == null rendert den deaktivierten Zustand',
      (tester) async {
    await tester.pumpWidget(_wrap(const AsmButton(label: 'Aus')));

    // Deaktiviert = 38 % Deckkraft und kein InkWell-Callback
    final opacity = tester.widget<Opacity>(
      find.descendant(of: find.byType(AsmButton), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, closeTo(0.38, 0.001));

    final inkWell = tester.widget<InkWell>(
      find.descendant(of: find.byType(AsmButton), matching: find.byType(InkWell)),
    );
    expect(inkWell.onTap, isNull);
  });

  testWidgets('erfuellt die Mindestgroesse von 48dp', (tester) async {
    await tester.pumpWidget(_wrap(AsmButton(label: 'X', onPressed: () {})));
    final size = tester.getSize(find.byType(AsmButton));
    expect(size.height, greaterThanOrEqualTo(48));
  });
}
```

- [ ] **Schritt 2: Tests laufen lassen** → **FAIL**
- [ ] **Schritt 3: `AsmButton` implementieren** (4 Varianten laut Design-System 5.1)
- [ ] **Schritt 4: Tests laufen lassen** → **PASS**
- [ ] **Schritt 5: Restliche sechs Widgets implementieren**, jeweils mit mindestens einem
      Widget-Test, der Rendering und Interaktion prüft
- [ ] **Schritt 6: Widget-Katalog-Screen anlegen** — `lib/core/widgets/_gallery_screen.dart`
      zeigt alle Komponenten in allen Zuständen untereinander. Nur im Debug-Build erreichbar
      (`if (kDebugMode)`), aber unbezahlbar zum Prüfen.
- [ ] **Schritt 7: Commit** — `feat(ui): add core widget library`

---

## Task 0.6: Router und Navigations-Shell

**Dateien:**
- Create: `lib/core/router/app_router.dart`, `lib/core/router/routes.dart`
- Create: `lib/core/widgets/asm_shell.dart` (BottomNav-Gerüst)
- Modify: `lib/app.dart`, `lib/main.dart`
- Test: `test/core/router/app_router_test.dart`

**Produziert:** `appRouterProvider`, Routen-Konstanten `AsmRoutes.home`, `.search`, `.create`,
`.chats`, `.profile`, `.listing(id)`, `.category(slug)`, `.chat(id)`, `.login`, `.register`

- [ ] **Schritt 1: Routen-Konstanten definieren**

```dart
// lib/core/router/routes.dart
abstract final class AsmRoutes {
  static const home = '/';
  static const search = '/search';
  static const create = '/create';
  static const chats = '/chats';
  static const profile = '/profile';

  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';

  static String category(String slug) => '/category/$slug';
  static String listing(String id) => '/listing/$id';
  static String chat(String id) => '/chat/$id';
  static String publicProfile(String id) => '/user/$id';

  static const settings = '/settings';
  static const legal = '/legal';
  static const favorites = '/favorites';
  static const myListings = '/my-listings';
}
```

- [ ] **Schritt 2: Failing Test**

```dart
// test/core/router/app_router_test.dart
import 'package:asm/core/router/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Detailroute enthaelt die Inserats-ID', () {
    expect(AsmRoutes.listing('abc-123'), '/listing/abc-123');
  });

  test('Kategorieroute nutzt den Slug', () {
    expect(AsmRoutes.category('langwaffen-saeg'), '/category/langwaffen-saeg');
  });
}
```

- [ ] **Schritt 3: Test laufen lassen** → **FAIL**, dann Datei anlegen → **PASS**

- [ ] **Schritt 4: `StatefulShellRoute` mit BottomNav aufbauen**

Fünf Branches (Start, Suchen, Erstellen, Chats, Profil) laut Design-System 5.9.
Der mittlere Eintrag ist ein erhöhter Kreis und pusht `/create` als Vollbild-Route
**außerhalb** der Shell (die BottomNav ist beim Erstellen nicht sichtbar).
Jeder Branch bekommt zunächst einen Platzhalter-Screen mit `AsmEmptyState`.

- [ ] **Schritt 5: Deep Links konfigurieren**

`android/app/src/main/AndroidManifest.xml`: `<intent-filter>` für Scheme `asm` und
für `https://asm-app.de/listing/*`.
`ios/Runner/Info.plist`: `CFBundleURLSchemes` mit `asm`, dazu Associated Domains
(kann in M8 nachgezogen werden).

- [ ] **Schritt 6: Manuell prüfen** — Alle fünf Tabs sind erreichbar, der aktive Tab ist
      `brandBright`, der Zurück-Button verhält sich pro Branch korrekt
- [ ] **Schritt 7: Commit** — `feat(router): add go_router shell with bottom navigation`

---

## Task 0.7: Sentry, Umgebungs-Konfiguration und CI

**Dateien:**
- Create: `lib/core/config/app_config.dart`, `env/example.json`
- Modify: `lib/main.dart`
- Create: `.github/workflows/ci.yml`

**Produziert:** `AppConfig.supabaseUrl`, `.supabaseAnonKey`, `.sentryDsn`, `.isProd`

- [ ] **Schritt 1: `env/example.json`**

```json
{
  "SUPABASE_URL": "https://xxxx.supabase.co",
  "SUPABASE_ANON_KEY": "eyJ...",
  "SENTRY_DSN": "",
  "ENVIRONMENT": "dev"
}
```

- [ ] **Schritt 2: `AppConfig`**

```dart
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');

  static bool get isProd => environment == 'prod';

  /// Wirft beim Start, wenn eine Pflichtvariable fehlt – besser ein lauter
  /// Absturz beim Entwickeln als ein stiller Fehler beim Nutzer.
  static void assertValid() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL/SUPABASE_ANON_KEY fehlen. '
        'Starte mit: flutter run --dart-define-from-file=env/dev.json',
      );
    }
  }
}
```

- [ ] **Schritt 3: `main.dart` mit Sentry-Wrapper**

Sentry mit `options.sendDefaultPii = false` (DSGVO, G-Regel) und
`tracesSampleRate = AppConfig.isProd ? 0.2 : 1.0`.

- [ ] **Schritt 4: Start-Kommando dokumentieren** in `README.md`:

```bash
flutter run --dart-define-from-file=env/dev.json
```

- [ ] **Schritt 5: GitHub Actions CI**

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: dart format --set-exit-if-changed .
      - run: flutter analyze --fatal-infos
      - run: flutter test --coverage
```

- [ ] **Schritt 6: Commit** — `chore: add app config, sentry and CI pipeline`

---

## Task 0.8: Lokalisierung und PLZ-Datensatz

**Dateien:**
- Create: `l10n.yaml`, `lib/l10n/app_de.arb`
- Create: `assets/data/plz.json`, `lib/core/utils/plz_lookup.dart`
- Create: `lib/core/utils/formatters.dart`
- Modify: `lib/app.dart`, `pubspec.yaml`
- Test: `test/core/utils/plz_lookup_test.dart`, `test/core/utils/formatters_test.dart`

**Produziert:** `context.l10n` (Extension auf `AppLocalizations`),
`PlzLookup.resolve(String plz)` → `({String city, double lat, double lng})?`,
`Formatters.price(int cents)`, `Formatters.relativeTime(DateTime)`, `Formatters.distance(double km)`

Ohne diesen Task verstößt jeder spätere Task gegen **G3** (keine hartcodierten Strings)
und **ADR-5** (PLZ statt GPS) lässt sich nicht umsetzen.

- [ ] **Schritt 1: `l10n.yaml`**

```yaml
arb-dir: lib/l10n
template-arb-file: app_de.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

In `pubspec.yaml` unter `flutter:` ergänzen: `generate: true`.
In `app.dart`: `localizationsDelegates: AppLocalizations.localizationsDelegates`,
`supportedLocales: const [Locale('de')]`, `locale: const Locale('de')`.

- [ ] **Schritt 2: Extension für kurzen Zugriff**

```dart
// lib/core/utils/l10n_extension.dart
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

- [ ] **Schritt 3: PLZ-Datensatz besorgen**

Freier Datensatz mit deutschen Postleitzahlen inklusive Koordinaten (z. B. der
OpenGeoDB-/Zeitverschiebung-Datensatz oder ein CSV-Export von OpenStreetMap-Daten,
beides frei nutzbar). Auf die vier Felder reduzieren und als JSON-Map ablegen:

```json
{ "76133": { "o": "Karlsruhe", "lat": 49.0093, "lng": 8.3858 } }
```

Ziel: unter 1,5 MB. Beim ersten Zugriff einmal laden und im Speicher halten.

- [ ] **Schritt 4: Failing Tests**

```dart
// test/core/utils/formatters_test.dart
void main() {
  test('price formatiert deutsch mit Euro-Zeichen', () {
    expect(Formatters.price(125000), '1.250,00 €');
    expect(Formatters.price(0), '0,00 €');
  });

  test('distance rundet sinnvoll', () {
    expect(Formatters.distance(0.4), '<1 km');
    expect(Formatters.distance(12.34), '12 km');
    expect(Formatters.distance(148.9), '149 km');
  });

  test('relativeTime nutzt deutsche Kurzformen', () {
    final now = DateTime(2026, 8, 28, 12);
    expect(Formatters.relativeTime(now.subtract(const Duration(minutes: 5)), now: now),
        'vor 5 Min.');
    expect(Formatters.relativeTime(now.subtract(const Duration(hours: 3)), now: now),
        'vor 3 Std.');
    expect(Formatters.relativeTime(now.subtract(const Duration(days: 2)), now: now),
        'vor 2 Tagen');
  });
}

// test/core/utils/plz_lookup_test.dart
void main() {
  test('loest eine bekannte PLZ auf', () async {
    final result = await PlzLookup.resolve('76133');
    expect(result?.city, 'Karlsruhe');
    expect(result?.lat, closeTo(49.01, 0.05));
  });

  test('gibt null bei unbekannter PLZ zurueck', () async {
    expect(await PlzLookup.resolve('00000'), isNull);
  });
}
```

- [ ] **Schritt 5: Tests laufen lassen** → **FAIL**, implementieren → **PASS**
- [ ] **Schritt 6: Commit** — `feat(core): add localization, formatters and postal code lookup`

### ✅ M0 abgeschlossen, wenn

- App startet auf echtem Android-Gerät im Tactical-Olive-Look
- Fünf Tabs navigierbar
- Alle Kern-Widgets existieren und sind im Widget-Katalog sichtbar
- `context.l10n` funktioniert, `PlzLookup.resolve('76133')` liefert Karlsruhe
- `flutter analyze` 0 Issues, `flutter test` grün
- CI läuft auf GitHub grün
- `docs/TOOLCHAIN.md` existiert

---

# Meilenstein M1 · Backend und Datenmodell

**Ergebnis:** Supabase-Projekt mit vollständigem Schema, RLS, Storage und Suchfunktion.
Kategorien sind eingespielt. Dart-Modelle und Repositories existieren und sind getestet.

> **Hinweis:** Die SQL-Dateien werden per Supabase CLI verwaltet:
> `supabase init`, `supabase link --project-ref <ref>`, `supabase db push`.
> Änderungen **nie** direkt im Supabase-Studio klicken – immer als Migration,
> sonst ist der Zustand nicht reproduzierbar.

---

## Task 1.1: Supabase-Projekt und CLI

- [ ] Projekt auf supabase.com anlegen, **Region `eu-central-1` (Frankfurt)** (G6)
- [ ] Supabase CLI installieren (`npm i -g supabase` oder Scoop) – benötigt Node
- [ ] `supabase init` im Projektordner, `supabase link --project-ref <ref>`
- [ ] `env/dev.json` mit URL und **anon**-Key füllen (nicht `service_role`, G7)
- [ ] Auth-Einstellungen im Dashboard: E-Mail-Bestätigung **an**, Site-URL `asm://`,
      Redirect-URL `asm://auth-callback` hinzufügen
- [ ] Commit — `chore(db): init supabase project`

---

## Task 1.2: Migration – Profile

**Dateien:** Create `supabase/migrations/0001_profiles.sql`

- [x] **Schritt 1: Migration schreiben**

```sql
-- 0001_profiles.sql
create extension if not exists "uuid-ossp";
create extension if not exists cube;
create extension if not exists earthdistance;
create extension if not exists pg_trgm;

create type public.user_role as enum ('user', 'moderator');

create table public.profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  username           text not null unique
                       check (char_length(username) between 3 and 24
                              and username ~ '^[a-zA-Z0-9_]+$'),
  display_name       text check (char_length(display_name) <= 40),
  avatar_path        text,
  bio                text check (char_length(bio) <= 500),
  postal_code        text check (postal_code ~ '^[0-9]{5}$'),
  city               text,
  lat                double precision,
  lng                double precision,
  birth_date         date,
  is_commercial      boolean not null default false,
  commercial_name    text,
  commercial_address text,
  role               public.user_role not null default 'user',
  is_banned          boolean not null default false,
  created_at         timestamptz not null default now(),
  last_seen_at       timestamptz not null default now(),
  deleted_at         timestamptz,
  constraint commercial_needs_details check (
    not is_commercial
    or (commercial_name is not null and commercial_address is not null)
  )
);

create index profiles_username_trgm on public.profiles using gin (username gin_trgm_ops);

-- Profil automatisch beim Registrieren anlegen
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'username',
      'user_' || substr(replace(new.id::text, '-', ''), 1, 10)
    )
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Volljaehrigkeits-Check, wird von den Listing-Policies genutzt
create or replace function public.is_adult()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((
    select birth_date is not null
       and birth_date <= (current_date - interval '18 years')
    from public.profiles
    where id = auth.uid()
  ), false);
$$;

create or replace function public.is_moderator()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select role = 'moderator' from public.profiles where id = auth.uid()),
    false);
$$;

-- RLS
alter table public.profiles enable row level security;

create policy profiles_select_all on public.profiles
  for select using (deleted_at is null);

create policy profiles_update_own on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

create policy profiles_moderator_all on public.profiles
  for all using (public.is_moderator());

-- Spaltenrechte: Geburtsdatum und Geschaeftsanschrift sind nicht oeffentlich
revoke all on public.profiles from anon, authenticated;

grant select (id, username, display_name, avatar_path, bio, postal_code, city,
              is_commercial, commercial_name, role, created_at, last_seen_at)
  on public.profiles to anon, authenticated;

grant update (username, display_name, avatar_path, bio, postal_code, city,
              lat, lng, birth_date, is_commercial, commercial_name,
              commercial_address, last_seen_at)
  on public.profiles to authenticated;
```

- [x] **Schritt 2: Anwenden** — `supabase db push`
- [x] **Schritt 3: Manuell verifizieren** — nur strukturell (Tabelle, Policies, Trigger,
      Funktionen), funktionaler Teil ausgelassen. Siehe [`DECISIONS.md`](DECISIONS.md).
  - Über die App-Registrierung (oder Supabase Studio → Auth → Add User) einen Nutzer anlegen
  - In `profiles` muss automatisch eine Zeile entstehen
  - Als anderer Nutzer eingeloggt: `select birth_date from profiles` muss **fehlschlagen**
- [x] **Schritt 4: Commit** — `feat(db): add profiles table with rls and auth trigger`

---

## Task 1.3: Migration – Kategorien und Seed

**Dateien:** Create `supabase/migrations/0002_categories.sql`, `supabase/seed/categories.sql`

**Produziert:** Tabelle `categories` mit den 8 Haupt- und ~60 Unterkategorien aus
[`00-SPEC.md` Abschnitt 5](00-SPEC.md#5-kategorie-taxonomie).

- [x] **Schritt 1: Schema** — `id`-Default auf `gen_random_uuid()` korrigiert, siehe
      [`DECISIONS.md`](DECISIONS.md)

```sql
-- 0002_categories.sql
create table public.categories (
  id                  uuid primary key default uuid_generate_v4(),
  parent_id           uuid references public.categories(id) on delete cascade,
  slug                text not null unique,
  name                text not null,
  icon                text,
  sort_order          int not null default 0,
  requires_age_18     boolean not null default false,
  requires_f_marking  boolean not null default false,
  requires_joule      boolean not null default false,
  requires_propulsion boolean not null default false,
  is_active           boolean not null default true
);

create index categories_parent_idx on public.categories(parent_id, sort_order);

alter table public.categories enable row level security;

create policy categories_select_all on public.categories
  for select using (is_active);

create policy categories_moderator_write on public.categories
  for all using (public.is_moderator());
```

- [x] **Schritt 2: Seed schreiben**

Alle 8 Hauptkategorien plus Unterkategorien aus der Spec. **Wichtig:** Die vier
`requires_*`-Flags werden auf Eltern **und** Kindern gesetzt (denormalisiert) – die
RLS-Policy für Inserate prüft nur die direkt zugewiesene Kategorie und soll keine
Rekursion brauchen.

```sql
-- supabase/seed/categories.sql (Auszug, Muster fuer alle 8)
insert into public.categories
  (slug, name, icon, sort_order, requires_age_18, requires_f_marking,
   requires_joule, requires_propulsion)
values
  ('asg-05j',            'ASGs bis 0,5 J',      'asg05j',    1, false, false, true,  true),
  ('langwaffen',         'Gewehre & MPs',       'rifle',     2, true,  true,  true,  true),
  ('pistolen',           'Pistolen',            'pistol',    3, true,  true,  true,  true),
  ('ersatzteile-tuning', 'Ersatzteile & Tuning','gear',      4, false, false, false, false),
  ('zubehoer',           'Zubehör',             'accessory', 5, false, false, false, false),
  ('ausruestung',        'Ausrüstung',          'vest',      6, false, false, false, false),
  ('bekleidung',         'Bekleidung',          'shirt',     7, false, false, false, false),
  ('sonstiges',          'Sonstiges',           'dots',      8, false, false, false, false);

insert into public.categories
  (parent_id, slug, name, sort_order, requires_age_18, requires_f_marking,
   requires_joule, requires_propulsion)
select p.id, v.slug, v.name, v.sort_order,
       p.requires_age_18, p.requires_f_marking,
       p.requires_joule, p.requires_propulsion
from (values
  ('langwaffen', 'langwaffen-saeg',        'S-AEG (Elektro)',      1),
  ('langwaffen', 'langwaffen-gbbr',        'GBBR (Gas)',           2),
  ('langwaffen', 'langwaffen-hpa',         'HPA',                  3),
  ('langwaffen', 'langwaffen-federdruck',  'Federdruck & Sniper',  4),
  ('langwaffen', 'langwaffen-shotgun',     'Shotguns',             5),
  ('langwaffen', 'langwaffen-support',     'Support & LMG',        6),
  ('langwaffen', 'langwaffen-sonstige',    'Sonstige Langwaffen',  7)
  -- ... alle weiteren Unterkategorien aus 00-SPEC.md Abschnitt 5 ergaenzen
) as v(parent_slug, slug, name, sort_order)
join public.categories p on p.slug = v.parent_slug;
```

- [x] **Schritt 3: Anwenden und zählen** — `select count(*) from categories;`
      Ergebnis: **72** (8 Haupt- + 64 Unterkategorien — die vollständige Taxonomie in
      `00-SPEC.md` hat mehr Unterkategorien als die hier im Plan geschätzten "~60";
      siehe [`DECISIONS.md`](DECISIONS.md))
- [x] **Schritt 4: Prüfen, dass Flags vererbt sind** — für `langwaffen%` (age_18/f_marking)
      und `asg-05j%` (alle vier Flags) geprüft, jeweils auf Eltern und allen Kindern korrekt

```sql
select slug, requires_age_18, requires_f_marking
from public.categories where slug like 'langwaffen%';
-- alle Zeilen muessen true/true zeigen
```

- [x] **Schritt 5: Commit** — `feat(db): add categories with asvz taxonomy seed`

---

## Task 1.4: Migration – Inserate und Bilder

**Dateien:** Create `supabase/migrations/0003_listings.sql`

- [x] **Schritt 1: Schema** — beide `uuid_generate_v4()`-Defaults auf `gen_random_uuid()`
      umgestellt (siehe Task 1.3 in [`DECISIONS.md`](DECISIONS.md))

```sql
-- 0003_listings.sql
create type public.listing_condition as enum
  ('neu','neuwertig','gebraucht','leichte_defekte','defekt','bastelobjekt');

create type public.listing_status as enum
  ('draft','active','reserved','sold','archived','blocked');

create type public.propulsion_type as enum
  ('saeg','aep','gbb','co2','hpa','federdruck','sonstige');

create type public.image_kind as enum ('photo','f_marking','ownership_proof');

create table public.listings (
  id            uuid primary key default uuid_generate_v4(),
  seller_id     uuid not null references public.profiles(id) on delete cascade,
  category_id   uuid not null references public.categories(id),
  title         text not null check (char_length(title) between 10 and 80),
  description   text not null check (char_length(description) between 30 and 5000),
  price_cents   int  not null check (price_cents >= 0 and price_cents <= 100000000),
  negotiable    boolean not null default false,
  is_giveaway   boolean not null default false,
  accepts_swap  boolean not null default false,
  condition     public.listing_condition not null,
  status        public.listing_status not null default 'draft',
  manufacturer  text,
  model         text,
  joule         numeric(4,2) check (joule is null or (joule >= 0.10 and joule <= 7.50)),
  propulsion    public.propulsion_type,
  caliber       text check (caliber in ('6mm','8mm')),
  has_f_marking boolean not null default false,
  is_modified   boolean not null default false,
  ships         boolean not null default false,
  pickup_only   boolean not null default true,
  postal_code   text not null check (postal_code ~ '^[0-9]{5}$'),
  city          text not null,
  lat           double precision not null,
  lng           double precision not null,
  view_count    int not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  published_at  timestamptz,
  bumped_at     timestamptz,
  sold_at       timestamptz,

  constraint giveaway_is_free check (not is_giveaway or price_cents = 0),
  constraint delivery_chosen  check (ships or pickup_only),
  -- Kernregel des Waffenrechts, direkt in der Datenbank:
  constraint f_marking_required_above_half_joule
    check (joule is null or joule <= 0.5 or has_f_marking),

  search_tsv tsvector generated always as (
      setweight(to_tsvector('german', coalesce(title, '')), 'A')
   || setweight(to_tsvector('german',
        coalesce(manufacturer, '') || ' ' || coalesce(model, '')), 'B')
   || setweight(to_tsvector('german', coalesce(description, '')), 'C')
  ) stored
);

create index listings_search_idx   on public.listings using gin (search_tsv);
create index listings_category_idx on public.listings (category_id, status, bumped_at desc);
create index listings_seller_idx   on public.listings (seller_id, status);
create index listings_geo_idx      on public.listings using gist (ll_to_earth(lat, lng));
create index listings_price_idx    on public.listings (price_cents) where status = 'active';

create table public.listing_images (
  id             uuid primary key default uuid_generate_v4(),
  listing_id     uuid not null references public.listings(id) on delete cascade,
  storage_path   text not null,
  kind           public.image_kind not null default 'photo',
  sort_order     int not null default 0,
  width          int,
  height         int,
  created_at     timestamptz not null default now()
);

create index listing_images_listing_idx
  on public.listing_images (listing_id, kind, sort_order);

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger listings_touch
  before update on public.listings
  for each row execute function public.touch_updated_at();

alter table public.listings enable row level security;
alter table public.listing_images enable row level security;

-- Oeffentlich lesbar: nur sichtbare Status, und Altersgate greift
create policy listings_public_read on public.listings
  for select using (
    status in ('active', 'reserved', 'sold')
    and (
      not exists (
        select 1 from public.categories c
        where c.id = listings.category_id and c.requires_age_18
      )
      or public.is_adult()
    )
  );

create policy listings_owner_read on public.listings
  for select using (seller_id = auth.uid());

create policy listings_owner_write on public.listings
  for insert with check (seller_id = auth.uid());

create policy listings_owner_update on public.listings
  for update using (seller_id = auth.uid()) with check (seller_id = auth.uid());

create policy listings_owner_delete on public.listings
  for delete using (seller_id = auth.uid());

create policy listings_moderator_all on public.listings
  for all using (public.is_moderator());

create policy listing_images_read on public.listing_images
  for select using (
    exists (select 1 from public.listings l where l.id = listing_id)
  );

create policy listing_images_owner_write on public.listing_images
  for all using (
    exists (
      select 1 from public.listings l
      where l.id = listing_id and l.seller_id = auth.uid()
    )
  );
```

- [x] **Schritt 2: Die Waffenrecht-Constraint testen** (das ist der wichtigste Test im Projekt)
      — bestätigt: exakt `new row violates check constraint "f_marking_required_above_half_joule"`

```sql
-- muss FEHLSCHLAGEN:
insert into public.listings (seller_id, category_id, title, description,
  price_cents, condition, joule, has_f_marking, postal_code, city, lat, lng)
values ('<uuid>', '<cat>', 'Testgewehr ohne F', 'Beschreibung mit mehr als dreissig Zeichen.',
  30000, 'gebraucht', 1.20, false, '76133', 'Karlsruhe', 49.0, 8.4);
-- ERWARTET: new row violates check constraint "f_marking_required_above_half_joule"
```

- [x] **Schritt 3: Altersgate testen** — nur strukturell (Policy-Definition geprüft), kein
      echter Nutzer ohne `birth_date` verfügbar. Siehe [`DECISIONS.md`](DECISIONS.md).
- [x] **Schritt 4: Commit** — `feat(db): add listings and images with age gate and f-marking constraint`

---

## Task 1.5: Migration – Favoriten, Blocks, Meldungen

**Dateien:** Create `supabase/migrations/0004_social.sql`

```sql
create table public.favorites (
  user_id    uuid not null references public.profiles(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, listing_id)
);

create table public.blocks (
  blocker_id uuid not null references public.profiles(id) on delete cascade,
  blocked_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint no_self_block check (blocker_id <> blocked_id)
);

create type public.report_target as enum ('listing','user','message');
create type public.report_status as enum ('open','reviewing','resolved','rejected');

create table public.reports (
  id          uuid primary key default uuid_generate_v4(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  target_type public.report_target not null,
  target_id   uuid not null,
  reason      text not null,
  details     text check (char_length(details) <= 1000),
  status      public.report_status not null default 'open',
  created_at  timestamptz not null default now(),
  handled_at  timestamptz,
  handled_by  uuid references public.profiles(id),
  resolution  text
);

create index reports_open_idx on public.reports (status, created_at)
  where status = 'open';

alter table public.favorites enable row level security;
alter table public.blocks    enable row level security;
alter table public.reports   enable row level security;

create policy favorites_own on public.favorites
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy blocks_own on public.blocks
  for all using (blocker_id = auth.uid()) with check (blocker_id = auth.uid());

create policy reports_insert_own on public.reports
  for insert with check (reporter_id = auth.uid());

create policy reports_read_own on public.reports
  for select using (reporter_id = auth.uid());

create policy reports_moderator on public.reports
  for all using (public.is_moderator());
```

**Meldegründe (fest verdrahtet, als Dart-Enum in `moderation/domain/report_reason.dart`):**
`verbotener_artikel`, `kein_f_kennzeichen`, `vollautomat`, `kein_besitznachweis`,
`betrugsverdacht`, `falsche_kategorie`, `beleidigung`, `spam`, `sonstiges`

- [x] Migration anwenden ( `id`-Default auf `gen_random_uuid()` umgestellt, siehe Task 1.3 in
      [`DECISIONS.md`](DECISIONS.md)), RLS nur strukturell geprüft — gleiche Einschränkung wie
      Task 1.2/1.4, kein echter Nutzer verfügbar
- [x] Commit — `feat(db): add favorites, blocks and reports`

---

## Task 1.6: Migration – Chat

**Dateien:** Create `supabase/migrations/0005_chat.sql`

```sql
create table public.conversations (
  id              uuid primary key default uuid_generate_v4(),
  listing_id      uuid not null references public.listings(id) on delete cascade,
  buyer_id        uuid not null references public.profiles(id) on delete cascade,
  seller_id       uuid not null references public.profiles(id) on delete cascade,
  last_message_at timestamptz,
  created_at      timestamptz not null default now(),
  constraint one_conversation_per_buyer_and_listing unique (listing_id, buyer_id),
  constraint buyer_is_not_seller check (buyer_id <> seller_id)
);

create index conversations_buyer_idx  on public.conversations (buyer_id, last_message_at desc);
create index conversations_seller_idx on public.conversations (seller_id, last_message_at desc);

create table public.messages (
  id              uuid primary key default uuid_generate_v4(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id       uuid not null references public.profiles(id) on delete cascade,
  body            text check (char_length(body) between 1 and 2000),
  image_path      text,
  created_at      timestamptz not null default now(),
  read_at         timestamptz,
  constraint message_has_content check (body is not null or image_path is not null)
);

create index messages_conversation_idx on public.messages (conversation_id, created_at desc);

create or replace function public.bump_conversation()
returns trigger language plpgsql as $$
begin
  update public.conversations
     set last_message_at = new.created_at
   where id = new.conversation_id;
  return new;
end;
$$;

create trigger messages_bump_conversation
  after insert on public.messages
  for each row execute function public.bump_conversation();

alter table public.conversations enable row level security;
alter table public.messages      enable row level security;

create policy conversations_participants on public.conversations
  for select using (buyer_id = auth.uid() or seller_id = auth.uid());

create policy conversations_buyer_create on public.conversations
  for insert with check (
    buyer_id = auth.uid()
    and not exists (
      select 1 from public.blocks b
      where (b.blocker_id = seller_id and b.blocked_id = auth.uid())
         or (b.blocker_id = auth.uid() and b.blocked_id = seller_id)
    )
  );

create policy messages_read on public.messages
  for select using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

create policy messages_insert on public.messages
  for insert with check (
    sender_id = auth.uid()
    and exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

-- Nur das Lesen-Flag darf nachtraeglich gesetzt werden
create policy messages_mark_read on public.messages
  for update using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
    and sender_id <> auth.uid()
  );

-- Realtime aktivieren
alter publication supabase_realtime add table public.messages;
```

- [x] Migration anwenden (`id`-Defaults auf `gen_random_uuid()`, siehe Task 1.3 in
      [`DECISIONS.md`](DECISIONS.md))
- [x] **Realtime geprüft** — per SQL statt Dashboard: `pg_publication_tables` bestätigt
      `messages` in `supabase_realtime`
- [x] Commit — `feat(db): add realtime chat schema`

---

## Task 1.7: Storage-Buckets

**Dateien:** Create `supabase/migrations/0006_storage.sql`

```sql
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('listing-images', 'listing-images', true,  10485760,
     array['image/jpeg','image/png','image/webp','image/heic']),
  ('avatars',        'avatars',        true,   2097152,
     array['image/jpeg','image/png','image/webp']),
  ('chat-images',    'chat-images',    false, 10485760,
     array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

-- Pfadkonvention: listing-images/<user_id>/<listing_id>/<uuid>.jpg
create policy "listing images public read" on storage.objects
  for select using (bucket_id = 'listing-images');

create policy "listing images owner write" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'listing-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "listing images owner delete" on storage.objects
  for delete to authenticated using (
    bucket_id = 'listing-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "avatars public read" on storage.objects
  for select using (bucket_id = 'avatars');

create policy "avatars owner write" on storage.objects
  for all to authenticated using (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  ) with check (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "chat images participant read" on storage.objects
  for select to authenticated using (
    bucket_id = 'chat-images'
    and exists (
      select 1 from public.conversations c
      where c.id::text = (storage.foldername(name))[1]
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

create policy "chat images participant write" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'chat-images'
    and exists (
      select 1 from public.conversations c
      where c.id::text = (storage.foldername(name))[1]
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );
```

- [x] Migration anwenden — 3 Buckets verifiziert (public/private und file_size_limit korrekt),
      alle 7 Policies vorhanden
- [x] **Testen:** nur strukturell — gleiche Einschränkung wie Task 1.2/1.4/1.5, kein zweiter
      echter Nutzer verfügbar für den Cross-User-Test
- [x] Commit — `feat(db): add storage buckets with per-user policies`

---

## Task 1.8: Such-Funktion (RPC)

**Dateien:** Create `supabase/migrations/0007_search.sql`

Das ist das Herzstück des Feeds. **Eine** Funktion bedient Startseite, Kategorie-Feed
und Suche.

```sql
create or replace function public.search_listings(
  p_query        text                default null,
  p_category     text                default null,  -- slug, inkl. Unterkategorien
  p_min_price    int                 default null,  -- in Cent
  p_max_price    int                 default null,
  p_conditions   text[]              default null,
  p_propulsions  text[]              default null,
  p_min_joule    numeric             default null,
  p_max_joule    numeric             default null,
  p_ships        boolean             default null,
  p_lat          double precision    default null,
  p_lng          double precision    default null,
  p_radius_km    int                 default null,
  p_sort         text                default 'newest', -- newest|price_asc|price_desc|distance
  p_limit        int                 default 24,
  p_offset       int                 default 0
)
returns table (
  id            uuid,
  title         text,
  price_cents   int,
  negotiable    boolean,
  condition     public.listing_condition,
  status        public.listing_status,
  city          text,
  postal_code   text,
  joule         numeric,
  has_f_marking boolean,
  ships         boolean,
  bumped_at     timestamptz,
  seller_id     uuid,
  category_slug text,
  cover_path    text,
  distance_km   double precision,
  total_count   bigint
)
language sql
stable
security invoker
set search_path = public
as $$
  with scope as (
    select c.id
    from public.categories c
    where p_category is null
       or c.slug = p_category
       or c.parent_id = (select id from public.categories where slug = p_category)
  ),
  filtered as (
    select
      l.*,
      cat.slug as category_slug,
      (select li.storage_path
         from public.listing_images li
        where li.listing_id = l.id and li.kind = 'photo'
        order by li.sort_order
        limit 1) as cover_path,
      case
        when p_lat is null or p_lng is null then null
        else earth_distance(ll_to_earth(l.lat, l.lng), ll_to_earth(p_lat, p_lng)) / 1000.0
      end as distance_km
    from public.listings l
    join public.categories cat on cat.id = l.category_id
    where l.status in ('active', 'reserved')
      and l.category_id in (select id from scope)
      and (p_query      is null or l.search_tsv @@ websearch_to_tsquery('german', p_query))
      and (p_min_price  is null or l.price_cents >= p_min_price)
      and (p_max_price  is null or l.price_cents <= p_max_price)
      and (p_conditions is null or l.condition::text = any(p_conditions))
      and (p_propulsions is null or l.propulsion::text = any(p_propulsions))
      and (p_min_joule  is null or l.joule >= p_min_joule)
      and (p_max_joule  is null or l.joule <= p_max_joule)
      and (p_ships      is null or l.ships = p_ships)
      and (
        p_radius_km is null or p_lat is null or p_lng is null
        -- earth_box nutzt den GiST-Index, ist aber nur eine Bounding-Box
        -- (liefert etwas zu viel). earth_distance filtert danach exakt.
        or (
              earth_box(ll_to_earth(p_lat, p_lng), p_radius_km * 1000)
                @> ll_to_earth(l.lat, l.lng)
          and earth_distance(ll_to_earth(l.lat, l.lng),
                             ll_to_earth(p_lat, p_lng)) <= p_radius_km * 1000
        )
      )
      and not exists (
        select 1 from public.blocks b
        where (b.blocker_id = auth.uid() and b.blocked_id = l.seller_id)
           or (b.blocker_id = l.seller_id and b.blocked_id = auth.uid())
      )
  )
  select
    f.id, f.title, f.price_cents, f.negotiable, f.condition, f.status,
    f.city, f.postal_code, f.joule, f.has_f_marking, f.ships,
    coalesce(f.bumped_at, f.published_at, f.created_at) as bumped_at,
    f.seller_id, f.category_slug, f.cover_path, f.distance_km,
    count(*) over () as total_count
  from filtered f
  order by
    case when p_sort = 'price_asc'  then f.price_cents end asc,
    case when p_sort = 'price_desc' then f.price_cents end desc,
    case when p_sort = 'distance'   then f.distance_km end asc nulls last,
    coalesce(f.bumped_at, f.published_at, f.created_at) desc
  limit  least(coalesce(p_limit, 24), 60)
  offset greatest(coalesce(p_offset, 0), 0);
$$;
```

> **Wichtig:** `security invoker` – die Funktion läuft mit den Rechten des Aufrufers,
> die RLS-Policies auf `listings` greifen also weiterhin. Mit `security definer` wäre
> das Altersgate ausgehebelt.

- [x] **Schritt 1: Migration anwenden**
- [x] **Schritt 2: Testdaten anlegen** — 20 Inserate über 8 Kategorien, Preise 1.200–65.000 Cent,
      8 Städte/PLZ, ein Test-User via Studio. Bleibt in der DB, siehe [`DECISIONS.md`](DECISIONS.md).
- [x] **Schritt 3: Jeden Filter einzeln prüfen** — Text+Kategorie+Preis+Radius+Sort (Plan-Beispiel),
      Kategorie-Vererbung, Status-Ein-/Ausschluss, Preis-Range+Sort, Propulsion-Array — alle korrekt

```sql
select title, price_cents, distance_km, total_count
from public.search_listings(
  p_query := 'g36 tuning',
  p_category := 'langwaffen',
  p_max_price := 50000,
  p_lat := 49.0069, p_lng := 8.4037, p_radius_km := 100,
  p_sort := 'distance'
);
```

- [x] **Schritt 4: `explain analyze`** — GiST-Geoindex wird bei Radius-Filtern natürlich
      gewählt. GIN-Textindex wird bei 20 Testzeilen vom Planner übersprungen (Seq Scan
      ist bei der Größe billiger) — mit `enable_seqscan = off` erzwungen und als valide
      nutzbar bestätigt. Erwartetes Verhalten bei kleiner Tabelle, kein Bug.
      Siehe [`DECISIONS.md`](DECISIONS.md).
- [x] **Schritt 5: Commit** — `feat(db): add search_listings rpc with filters and distance`

---

## Task 1.9: Dart-Modelle und Repositories

**Dateien:**
- Create: `lib/core/supabase/supabase_provider.dart`
- Create: `lib/features/categories/domain/category.dart`, `data/category_repository.dart`
- Create: `lib/features/listings/domain/listing.dart`, `listing_summary.dart`,
  `listing_filter.dart`, `data/listing_repository.dart`
- Create: `lib/features/profile/domain/profile.dart`, `data/profile_repository.dart`
- Create: `lib/core/errors/app_exception.dart`, `error_mapper.dart`
- Test: `test/features/listings/domain/listing_test.dart`,
  `test/features/listings/data/listing_repository_test.dart`

**Produziert (Signaturen, auf die spätere Tasks bauen):**

```dart
// lib/core/supabase/supabase_provider.dart
final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

// lib/features/listings/data/listing_repository.dart
abstract interface class ListingRepository {
  Future<({List<ListingSummary> items, int total})> search(
    ListingFilter filter, {int limit = 24, int offset = 0});
  Future<Listing> byId(String id);
  Future<List<Listing>> bySeller(String sellerId, {ListingStatus? status});
  Future<String> create(ListingDraft draft);
  Future<void> update(String id, ListingDraft draft);
  Future<void> setStatus(String id, ListingStatus status);
  Future<void> delete(String id);
  Future<void> incrementView(String id);
}

// lib/features/categories/data/category_repository.dart
abstract interface class CategoryRepository {
  Future<List<Category>> roots();
  Future<List<Category>> children(String parentSlug);
  Future<Category> bySlug(String slug);
}
```

- [x] **Schritt 1: Fehler-Mapping zuerst**

```dart
// lib/core/errors/app_exception.dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

final class NetworkException extends AppException {
  const NetworkException() : super('Keine Verbindung. Bitte prüfe dein Netzwerk.');
}
final class AuthRequiredException extends AppException {
  const AuthRequiredException() : super('Dafür musst du angemeldet sein.');
}
final class AgeRestrictedException extends AppException {
  const AgeRestrictedException()
      : super('Dieser Bereich ist erst ab 18 Jahren zugänglich.');
}
final class NotFoundException extends AppException {
  const NotFoundException() : super('Das Inserat existiert nicht mehr.');
}
final class ValidationException extends AppException {
  const ValidationException(super.message);
}
final class UnknownException extends AppException {
  const UnknownException([super.message = 'Etwas ist schiefgelaufen.']);
}
```

`error_mapper.dart` übersetzt `PostgrestException`, `AuthException`, `StorageException`
und `SocketException` in diese Typen. **Kein rohes Supabase-Exception-Objekt darf je die
UI erreichen** – der Nutzer soll nie einen Postgres-Fehlercode sehen.

- [x] **Schritt 2: freezed-Modelle** für `Category`, `ListingSummary`, `Listing`,
      `ListingDraft`, `ListingFilter`, `Profile` mit `fromJson` — brauchte freezed 2→4
      (Dart-3.13-Inkompatibilität), siehe [`DECISIONS.md`](DECISIONS.md)
- [x] **Schritt 3: `dart run build_runner build --delete-conflicting-outputs`** — `build.yaml`
      scoped auf `lib/features/**/domain/*.dart`, siehe [`DECISIONS.md`](DECISIONS.md)
- [x] **Schritt 4: Repository-Tests mit `mocktail`** — `SupabaseClient` gemockt; die
      `search()`-RPC selbst läuft über einen injizierbaren `RpcCaller` statt direktem
      `.rpc()`-Mocking (`PostgrestFilterBuilder` ist mit mocktail nicht sauber mockbar,
      bekanntes Ökosystem-Problem, siehe [`DECISIONS.md`](DECISIONS.md)). Parameter-Mapping
      und Antwort-Mapping beide getestet.
- [x] **Schritt 5: Ein Integrationstest gegen die echte Dev-Datenbank** — läuft in
      `integration_test/category_repository_test.dart`, bestätigt live 8 Wurzelkategorien
- [x] **Schritt 6: Commit** — `feat(data): add domain models and supabase repositories`

### ✅ M1 abgeschlossen, wenn

- [x] Alle 7 Migrationen sind angewendet und im Repo
- [x] 72 Kategorien in der DB (nicht 68, siehe Task 1.3 in [`DECISIONS.md`](DECISIONS.md))
- [x] Ein Inserat über 0,5 J ohne F-Kennzeichen lässt sich **nicht** anlegen (DB-Constraint) —
      live verifiziert, exakte erwartete Fehlermeldung (Task 1.4)
- [x] Ein Nutzer ohne Geburtsdatum sieht **keine** Inserate aus `langwaffen`/`pistolen` — nur
      strukturell verifiziert (Policy-Definition korrekt), kein echter Minderjährigen-Testaccount
      verfügbar. Siehe die offene Nachhol-Notiz zu Task 1.2/1.4 in [`DECISIONS.md`](DECISIONS.md).
- [x] `search_listings` liefert mit allen Filterkombinationen plausible Ergebnisse — mit 20
      echten Testinseraten verifiziert (Task 1.8)
- [x] Repository-Tests grün — 55/55 Unit-Tests, `flutter analyze` 0 Issues

---

# Meilenstein M2 · Authentifizierung und Profil

**Ergebnis:** Registrieren, E-Mail bestätigen, einloggen, Profil pflegen, Account löschen.
Auth-Guards im Router greifen.

## Task 2.1: Auth-Repository und Session-State

**Dateien:** `lib/features/auth/data/auth_repository.dart`,
`lib/features/auth/presentation/auth_controller.dart`,
Test: `test/features/auth/auth_controller_test.dart`

**Produziert:** `authStateProvider` (`AsyncValue<AsmUser?>`),
`AuthRepository.signUp/signIn/signOut/resetPassword/deleteAccount`,
`currentUserProvider`, `isLoggedInProvider`, `isAdultProvider`

- [x] Test: `authStateProvider` liefert `null` ohne Session, `AsmUser` mit Session
- [x] Test: Nach `signOut` ist der State wieder `null`
- [x] Implementieren über `supabase.auth.onAuthStateChange` als Stream-Provider
- [x] Commit — `feat(auth): add auth repository and session state` (`e644bc4`) — zusätzlich
      `AsmUser` (Domainmodell, nicht in "Dateien" gelistet, aber von "Produziert" verlangt)
      und `isAdultProvider` (RPC `is_adult`, noch ungetestet). Details in DECISIONS.md.

## Task 2.2: Registrierungs-Screen

**Dateien:** `lib/features/auth/presentation/register_screen.dart`,
`widgets/password_strength_bar.dart`, Test: `register_screen_test.dart`

Felder: Nutzername, E-Mail, Passwort, Geburtsdatum, zwei Pflicht-Checkboxen
(AGB + Datenschutz mit Links).

Validierung (in `lib/core/utils/validators.dart`, **unit-getestet**):

| Feld | Regel | Fehlertext |
|---|---|---|
| Nutzername | 3–24, nur `a-zA-Z0-9_`, nicht vergeben | "Nutzername ist vergeben" |
| E-Mail | RFC-nahe Regex | "Bitte gib eine gültige E-Mail-Adresse ein" |
| Passwort | min. 8 Zeichen, mind. 1 Ziffer, mind. 1 Buchstabe | "Mindestens 8 Zeichen mit Zahl und Buchstabe" |
| Geburtsdatum | Datum in der Vergangenheit, Alter ≥ 14 | "Die Nutzung ist erst ab 14 Jahren erlaubt" |
| Checkboxen | beide gesetzt | "Bitte bestätige AGB und Datenschutz" |

- [x] Tests: Jede Validierungsregel einzeln, plus ein Widget-Test "Absenden ist deaktiviert,
      solange ein Feld ungültig ist" — 20 Tests in `validators_test.dart` (inkl. `validateConsent`,
      nicht nur die vier Tabellen-Felder) + 5 in `register_screen_test.dart`
- [x] Nach erfolgreicher Registrierung: Screen "E-Mail bestätigen" mit
      "Erneut senden"-Button (60 s Cooldown) — als interner Zustand von `RegisterScreen`,
      keine eigene Route. Echt getestet: kompletter Flow lief auf dem Emulator gegen das
      echte Dev-Supabase-Projekt durch (Registrierung → Bestätigungsscreen → Erneut senden
      → 60s-Cooldown zählt runter). Details und ein dabei gefundener, unabhängiger
      Startup-Bug in DECISIONS.md.
- [x] Commit — `feat(auth): add registration flow with validation` (`a386992`)

## Task 2.3: Login, Passwort vergessen, Deep-Link-Callback

- [x] Login-Screen mit E-Mail/Passwort, Fehlermeldung bei falschen Daten
      (**nicht** "Nutzer existiert nicht" – das ist eine Nutzer-Enumeration; immer
      "E-Mail oder Passwort ist falsch") — echt auf dem Emulator gegen das Dev-Projekt
      getestet: falsches Passwort für den Task-2.2-Testaccount zeigt exakt diese Meldung,
      nie die rohe Supabase-Fehlermeldung
- [x] "Passwort vergessen" → `resetPasswordForEmail` mit Redirect `asm://reset-password` —
      `asm://reset-password` zusätzlich zu `supabase/config.toml`s `additional_redirect_urls`
      hinzugefügt und gepusht (war nur `asm://auth-callback` gelistet, siehe Task 1.1)
- [x] Deep-Link-Handling: `asm://auth-callback` setzt die Session und leitet auf `/` weiter —
      zusätzlich `asm://reset-password` → `passwordRecovery` → `/reset-password`-Screen
      (nicht explizit im Plan, aber ohne den Screen ist "Passwort vergessen" nicht nutzbar,
      siehe DECISIONS.md). Session-Handling selbst kommt automatisch von `supabase_flutter`
      (bestätigt im Paket-Quellcode, nicht angenommen) — eigener Code ist nur der globale
      Redirect-Listener in `app.dart`, der auf `AuthChangeEvent` reagiert.
      **Nicht vollständig End-to-End getestet:** das tatsächliche Antippen eines
      Bestätigungs-/Reset-Links aus einer echten E-Mail — dafür bräuchte es ein
      erreichbares Postfach, und das Supabase-Projekt-Limit (`email_sent = 2`/Stunde)
      war durch die Tests in Task 2.2 bereits ausgeschöpft. Alles andere (native
      `asm://`-Registrierung, Redirect-Allowlist, das eigene Redirect-Listener-Verhalten)
      ist verifiziert — nur die reine Paket-interne Code-Exchange-Strecke nicht real
      durchlaufen. Siehe DECISIONS.md für Details und wie es nachgeholt werden kann.
- [x] Commit — `feat(auth): add login, password reset and deep link callback` (`85232fd`)

## Task 2.4: Auth-Guards im Router

**Dateien:** `lib/core/router/guards.dart`, Modify `app_router.dart`

Regeln:

| Route | Bedingung | Sonst |
|---|---|---|
| `/create`, `/chats`, `/favorites`, `/my-listings`, `/profile` | eingeloggt | Login-Sheet, danach zurück zur Zielroute |
| `/create` | E-Mail bestätigt | Hinweis "Bitte bestätige zuerst deine E-Mail" |
| Kategorie mit `requires_age_18` | `isAdult` | Alters-Sperrseite mit Erklärung |

- [x] Test: `redirect` gibt für `/create` ohne Session `/login?from=/create` zurück
- [x] Commit — `feat(router): add auth and age guards`

## Task 2.5: Profil ansehen und bearbeiten

- [x] Eigenes Profil: Avatar, Nutzername, Mitglied seit, aktive Inserate, Favoriten,
      Einstellungen, Rechtstexte, Abmelden — Favoriten/Einstellungen als Platzhalter
      (echte Inhalte sind Task 5.2 bzw. Task 7.1), Rechtstexte verlinken extern auf
      `asm-app.de` (Task 8.0), Details in DECISIONS.md
- [x] Profil bearbeiten: Avatar-Upload (Bucket `avatars`, auf 512 px komprimiert),
      Anzeigename, Bio, PLZ mit Ort-Auflösung aus `assets/data/plz.json`,
      Schalter "Ich verkaufe gewerblich" mit Pflichtfeldern
- [x] Fremdprofil: öffentliche Daten + aktive Inserate + Buttons "Melden" und "Blockieren"
      — echte Aktion, volles Melde-Sheet mit den 9 Gründen aus Task 1.5 ist Task 7.1
- [x] Commit — `feat(profile): add profile view and edit screens`

## Task 2.6: Account löschen (Store-Pflicht)

**Dateien:** `supabase/functions/delete-account/index.ts`,
`lib/features/profile/presentation/delete_account_screen.dart`

Löschen muss serverseitig laufen, weil der Client `auth.users` nicht löschen darf.
Edge Function mit `service_role`-Key (nur dort, nie im Client, G7):

1. Session prüfen, `user_id` ermitteln
2. Storage-Objekte des Nutzers löschen
3. `auth.admin.deleteUser(user_id)` → Cascade räumt `profiles`, `listings`, `messages` auf

- [x] Bestätigungsdialog: Nutzer muss seinen Nutzernamen eintippen
- [x] Zusätzlich eine öffentliche Webseite `asm-app.de/account-loeschen` (Google-Play-Pflicht)
      — bereits in Task 8.0 gebaut, hier nur geprüft und einen veralteten Pfad korrigiert
- [x] Test: Nach dem Löschen liefert Login mit denselben Daten einen Fehler — voller
      destruktiver Test mit einem echten bestätigten Nutzer live durchgespielt, liefert
      korrekt "E-Mail oder Passwort ist falsch", siehe DECISIONS.md
- [x] Commit — `feat(profile): add in-app account deletion`

## Task 2.7: Splash, Onboarding und Willkommen (F19)

**Dateien:** `lib/features/onboarding/presentation/onboarding_screen.dart`,
`splash_screen.dart`, `welcome_screen.dart`,
Test: `test/features/onboarding/onboarding_screen_test.dart`

**Produziert:** `hasSeenOnboardingProvider` (aus `shared_preferences`), Route `/onboarding`

- [x] Splash: nur `AsmColors.bg` + Logo, hält, bis Session und Kategorien geladen sind
      (max. 3 s, danach trotzdem weiter). Zusätzlich `flutter_native_splash`, damit
      zwischen Systemsplash und App-Splash kein weißer Blitz entsteht — **Logo ist ein
      Platzhalter** (Text "ASM"), echtes Logo kommt am Ende des Milestones, siehe DECISIONS.md
- [x] Onboarding, 3 Seiten, `PageView` mit Punktindikator, "Überspringen" oben rechts:
  1. **"Gear finden, das wirklich passt."** — Kategorien vom S-AEG bis zum Plattenträger
  2. **"Sicher handeln."** — F-Kennzeichen-Pflicht, Besitznachweis, 18+-Regel
  3. **"Direkt verhandeln."** — Chat mit dem Verkäufer
- [x] Willkommen-Screen: "Konto erstellen" (primary) / "Anmelden" (secondary) /
      "Erstmal umsehen" (ghost → als Gast in den Feed)
- [x] Onboarding erscheint nur beim allerersten Start (`shared_preferences`-Flag)
- [x] Test: Bei gesetztem Flag leitet der Router direkt auf `/` weiter
- [x] Test: "Überspringen" setzt das Flag und navigiert zum Willkommen-Screen
- [x] Commit — `feat(onboarding): add splash, onboarding and welcome screens`

### ✅ M2 abgeschlossen, wenn

Erststart → Onboarding → Registrieren → E-Mail bestätigen → einloggen → Profil ausfüllen
→ abmelden → wieder einloggen → Account löschen funktioniert vollständig auf einem echten
Gerät. Beim zweiten Start wird das Onboarding übersprungen. Ein Aufruf von `/create` ohne
Session landet im Login und danach wieder auf `/create`.

---

# Meilenstein M3 · Kategorien, Feed und Suche

**Ergebnis:** Man kann stöbern, suchen und filtern. Der Feed lädt seitenweise nach.

## Task 3.1: Kategorie-Übersicht und Kategorie-Feed
- [x] Startseite: Grid mit 8 Kategorie-Kacheln (`CategoryTile`), darunter Sektion
      "Neu eingestellt" mit horizontaler Liste
- [x] Kategorie-Screen: Unterkategorien als Chip-Reihe oben, darunter der gefilterte Feed
- [x] Kategorie-Icons als SVG einbinden (Design-System Abschnitt 6)
- [x] Commit — `feat(categories): add category overview and category feed`

## Task 3.2: Paginierter Feed
**Produziert:** `listingFeedProvider(ListingFilter)` als `AsyncNotifier` mit
`loadMore()` und `refresh()`

- [x] `AsmSkeleton.listingGrid` beim ersten Laden, Shimmer-Karten beim Nachladen
- [x] Pull-to-Refresh
- [x] Nachladen bei 80 % Scrolltiefe, `total_count` aus der RPC begrenzt das Nachladen
- [x] Grid-/Listen-Umschalter, Auswahl in `shared_preferences`
- [x] `AsmEmptyState` bei 0 Treffern, `AsmErrorView` mit Retry bei Fehler
- [x] Test: Provider lädt Seite 1, `loadMore()` hängt Seite 2 an, `total` wird respektiert
- [x] Commit — `feat(listings): add paginated feed with pull to refresh`

## Task 3.3: Suche
- [ ] Suchfeld mit 350 ms Debounce
- [ ] Suchverlauf (letzte 10, lokal in `shared_preferences`, einzeln löschbar)
- [ ] Leerer Zustand mit Vorschlägen (beliebte Kategorien)
- [ ] Commit — `feat(search): add search with history and debounce`

## Task 3.4: Filter-Sheet
Bottom-Sheet mit: Kategorie, Preis (RangeSlider + zwei Eingabefelder), Zustand
(Mehrfachauswahl-Chips), Antriebsart, Joule-Bereich, Versand/Abholung, PLZ + Umkreis
(5/10/25/50/100/200 km / ganz DE), Sortierung.

- [ ] Aktive Filter als entfernbare Chips über dem Feed
- [ ] "Alle zurücksetzen"
- [ ] Anzahl aktiver Filter als Badge am Filter-Icon
- [ ] Joule- und Antriebsart-Filter nur sichtbar, wenn die gewählte Kategorie
      `requires_joule` bzw. `requires_propulsion` hat
- [ ] Test: `ListingFilter.activeCount` zählt korrekt; `copyWith` + Reset funktionieren
- [ ] Commit — `feat(search): add filter sheet`

---

# Meilenstein M4 · Inserat erstellen

**Ergebnis:** Ein vollständiges Inserat inklusive Fotos, F-Kennzeichen und Besitznachweis
lässt sich anlegen und veröffentlichen. **Der aufwendigste Meilenstein.**

> ⚠️ **Vor dem ersten Task hier: Altersgate/RLS-Konflikt aus Task 3.1 auflösen.**
> Sobald irgendwo in M4 (oder später, z. B. Chat-Start) ein Kauf-/Kontaktieren-Button für
> ein Inserat entsteht, greift ein offener Punkt: Die RLS-Policy `listings_public_read`
> (Task 1.4) blockt `requires_age_18`-Zeilen aktuell **komplett** auf SELECT-Ebene für jeden
> Nicht-Erwachsenen — Gäste und verifizierte Minderjährige bekommen so ein Inserat gar nicht
> erst zurück. Das widerspricht der Nutzer-Vorgabe vom 2026-08-30: Inserate bleiben für
> **alle** ansehbar, nur der Kauf wird für nicht-volljährige/nicht eingeloggte Nutzer
> gesperrt. Voller Kontext in [`DECISIONS.md`](DECISIONS.md), Eintrag
> "Task 3.1 · Altersgate bewusst nicht verdrahtet". **Mit dem Nutzer abstimmen, bevor hier
> Code entsteht** — das ist eine Datenmodell-/Policy-Entscheidung (RLS ändern vs. eigene
> View/RPC), keine, die Sonnet allein trifft. `blocksForAge()` in `guards.dart` ist fertig
> und getestet und wartet auf genau diesen Moment.

## Task 4.1: Bild-Pipeline
**Dateien:** `lib/features/listings/data/image_service.dart`, Test dazu

**Produziert:** `ImageService.pickFromGallery({int max})`, `.pickFromCamera()`,
`.compress(File)` → JPEG max. 1600 px lange Kante bei Qualität 80,
`.upload(File, {required String listingId, required ImageKind kind})` → `storage_path`

- [ ] Komprimierung **vor** dem Upload, auf dem Gerät (spart Datenvolumen und Zeit)
- [ ] Uploads laufen parallel, max. 3 gleichzeitig
- [ ] Fortschrittsanzeige pro Bild
- [ ] Test: Ein 4000×3000-Testbild wird auf max. 1600 px verkleinert und ist kleiner als das Original
- [ ] Commit — `feat(listings): add image pick, compress and upload service`

## Task 4.2: Erstellen-Flow, 4 Schritte
Schrittanzeige oben, Entwurf wird nach jedem Schritt lokal gespeichert
(App-Absturz darf keine Arbeit vernichten).

**Schritt 1 – Kategorie:** Zwei Ebenen, Suchfeld über allen Kategorien
**Schritt 2 – Fotos:** Grid mit Drag-to-Reorder, erstes Bild ist das Titelbild, 1–12 Stück.
Wenn die Kategorie `requires_f_marking` hat: zusätzlicher Pflicht-Slot "F-Kennzeichen"
mit Erklärtext und Beispielbild. Immer: Pflicht-Slot "Besitznachweis" mit Erklärung
("Zettel mit deinem Nutzernamen *{username}* und dem heutigen Datum *{date}* neben den Artikel legen").
**Schritt 3 – Details:** Titel, Beschreibung, Zustand, Hersteller (Autocomplete), Modell,
bei Bedarf Joule + Antriebsart + Kaliber + "umgebaut", Preis, VB, Tausch, Verschenken
**Schritt 4 – Versand & Ort:** Versand/Abholung, PLZ (Ort wird aufgelöst), Vorschau, Veröffentlichen

- [ ] Jeder Schritt validiert vor dem Weiterblättern, Fehler werden am Feld angezeigt
- [ ] Der Veröffentlichen-Button ist deaktiviert, bis alles gültig ist
- [ ] Nach dem Veröffentlichen: Erfolgs-Screen mit Teilen-Button und "Inserat ansehen"
- [ ] Test: Ein Entwurf mit `joule = 1.2` und ohne F-Kennzeichen-Bild lässt sich
      **nicht** absenden (Client-Validierung), und der Server lehnt ihn zusätzlich ab
      (DB-Constraint aus Task 1.4)
- [ ] Commit — `feat(listings): add 4-step listing creation flow`

## Task 4.3: Bearbeiten und Statuswechsel
- [ ] "Meine Inserate" mit Tabs Aktiv / Reserviert / Verkauft / Entwürfe
- [ ] Aktionen pro Inserat: Bearbeiten, Hochschieben (alle 14 Tage, ASVZ-Regel §7),
      Als reserviert markieren, Als verkauft markieren, Löschen
- [ ] Beim Löschen: Bestätigung + Storage-Objekte mit entfernen
- [ ] Commit — `feat(listings): add listing management and status changes`

---

# Meilenstein M5 · Detailseite und Favoriten

## Task 5.1: Detailseite
- [ ] Bildergalerie mit Seitenindikator, Tap öffnet Vollbild mit Pinch-Zoom
- [ ] Titel, Preis (mit VB/Verschenken/Tausch-Badges), Zustands-Badge
- [ ] Attributtabelle: Hersteller, Modell, Joule, Antriebsart, Kaliber, F-Kennzeichen,
      umgebaut — nur die Zeilen anzeigen, die gefüllt sind
- [ ] Bei über 0,5 J: Hinweisbox "Abgabe nur an Personen ab 18. Transport nur im
      verschlossenen Behältnis (§42a WaffG)."
- [ ] Beschreibung mit "Mehr anzeigen" ab 6 Zeilen
- [ ] Verkäufer-Karte: Avatar, Name, Mitglied seit, aktive Inserate, Badge "Gewerblich"
- [ ] Ort + Entfernung, Versandhinweis
- [ ] Untere Leiste: "Nachricht schreiben" (primary) + Favoriten-Herz + Teilen
- [ ] Overflow-Menü: Melden, Verkäufer blockieren
- [ ] Beim eigenen Inserat: statt "Nachricht" → "Bearbeiten"
- [ ] `incrementView` einmal pro Session pro Inserat
- [ ] Hero-Animation vom Feed-Bild
- [ ] Commit — `feat(listings): add listing detail screen`

## Task 5.2: Favoriten
- [ ] Optimistisches Umschalten (Herz reagiert sofort, Rollback bei Fehler)
- [ ] Favoriten-Screen als Liste, Wischen zum Entfernen
- [ ] Badge auf verkauften Favoriten
- [ ] Test: Fehlerfall setzt den Zustand zurück
- [ ] Commit — `feat(favorites): add favorites with optimistic toggle`

---

# Meilenstein M6 · Chat

**Ergebnis:** Zwei Nutzer können in Echtzeit über ein Inserat schreiben und bekommen
Push-Benachrichtigungen.

## Task 6.1: Chat-Repository und Realtime-Stream
**Produziert:** `ChatRepository.conversations()`, `.messages(conversationId)` (Stream),
`.send(conversationId, body)`, `.getOrCreateConversation(listingId)`, `.markRead(conversationId)`

```dart
Stream<List<Message>> messages(String conversationId) {
  return _client
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('conversation_id', conversationId)
      .order('created_at')
      .map((rows) => rows.map(Message.fromJson).toList());
}
```

- [ ] Test: Der Stream gibt neue Nachrichten aus, ohne dass neu geladen wird
- [ ] Commit — `feat(chat): add chat repository with realtime stream`

## Task 6.2: Chatliste und Chat-Detail
- [ ] Chatliste: Inseratsbild, Titel, Gegenüber, letzte Nachricht, Zeit, Ungelesen-Punkt,
      sortiert nach `last_message_at`
- [ ] Chat-Detail: `ChatBubble` laut Design-System 5.6, Inserats-Karte oben angeheftet,
      Eingabefeld mit automatischer Höhe (max. 5 Zeilen)
- [ ] Optimistisches Senden: Nachricht erscheint sofort als "wird gesendet", bei Fehler
      Retry-Symbol
- [ ] Beim Öffnen `markRead`, Ungelesen-Badge in der BottomNav aktualisiert sich
- [ ] Overflow: Melden, Blockieren, Chat löschen
- [ ] Leerer Zustand: "Noch keine Nachrichten. Frag den Verkäufer, ob der Artikel noch da ist."
- [ ] Commit — `feat(chat): add conversation list and chat screen`

## Task 6.3: Push-Benachrichtigungen
**Dateien:** `supabase/migrations/0008_device_tokens.sql`,
`supabase/functions/notify-on-message/index.ts`,
`lib/features/notifications/`

- [ ] Firebase-Projekt anlegen, `google-services.json` und `GoogleService-Info.plist`
      einbinden (**beide in `.gitignore`**)
- [ ] Pakete: `firebase_core`, `firebase_messaging`, `flutter_local_notifications`
- [ ] Tabelle `device_tokens (user_id, token, platform, updated_at)` mit RLS
- [ ] Token bei Login registrieren, bei Logout löschen
- [ ] Berechtigung erst **kontextbezogen** anfragen (nach der ersten gesendeten Nachricht,
      nicht beim App-Start) — deutlich höhere Zustimmungsrate
- [ ] Datenbank-Webhook auf `messages INSERT` → Edge Function → FCM v1 API
- [ ] Notification-Tap öffnet den richtigen Chat (Deep Link)
- [ ] Keine Push, wenn der Empfänger den Chat gerade offen hat
- [ ] Test auf **echten Geräten**, iOS und Android, App im Vordergrund/Hintergrund/beendet
- [ ] Commit — `feat(notifications): add fcm push for new messages`

---

# Meilenstein M7 · Moderation, Recht und Sicherheit

## Task 7.1: Melden und Blockieren
- [ ] Melde-Sheet mit den 9 Gründen aus Task 1.5 + optionalem Freitext
- [ ] Bestätigung: "Danke. Wir prüfen die Meldung innerhalb von 24 Stunden."
- [ ] Blockieren: beidseitig unsichtbar (greift in `search_listings` und den Chat-Policies)
- [ ] Liste blockierter Nutzer in den Einstellungen, entsperrbar
- [ ] Commit — `feat(moderation): add report and block flows`

## Task 7.2: Rechtstexte in der App

> **Voraussetzung:** Die vier Markdown-Dateien in `assets/legal/` entstehen bereits in
> **Task 8.0 Teil A**. Wurde 8.0A vorgezogen (empfohlen), sind sie hier schon da und
> dieser Task besteht nur noch aus Anzeige und Verlinkung. Falls nicht: erst 8.0A
> Schritt 2 machen, damit App und Website dieselbe Quelle nutzen.

- [ ] Vier Markdown-Dateien in `assets/legal/` vorhanden: `impressum.md`, `datenschutz.md`,
      `agb.md`, `nutzungsbedingungen.md` (Quelle: Task 8.0A)
- [ ] Anzeige über `flutter_markdown` im App-Theme (kein WebView – schneller, offline, konsistent)
- [ ] Verlinkt aus: Registrierung (Pflicht-Checkboxen), Einstellungen, Profil
- [ ] **Inhaltlich vom Anwalt prüfen lassen** – die Entwürfe sind nur Platzhalter
- [ ] Nutzungsbedingungen enthalten: verbotene Artikel, 18+-Regel, F-Kennzeichen-Pflicht,
      Besitznachweis-Pflicht, Null-Toleranz-Klausel für anstößige Inhalte (Apple 1.2), Meldeverfahren
- [ ] Gegenprobe: Der in der App angezeigte Text ist identisch mit dem auf der Website
- [ ] Commit — `feat(legal): add in-app legal documents`

## Task 7.3: Sicherheits-Durchgang
- [ ] **Jede** Tabelle in `public` prüfen: RLS aktiv, mindestens eine Policy
```sql
select tablename, rowsecurity from pg_tables where schemaname = 'public';
select tablename, count(*) from pg_policies where schemaname='public' group by 1;
```
- [ ] Mit einem zweiten Testkonto versuchen: fremdes Inserat bearbeiten, fremden Chat lesen,
      fremdes Bild überschreiben, Inserate über 0,5 J ohne Geburtsdatum abrufen —
      **alles muss scheitern**
- [ ] Kein `service_role`-Key im Client (`grep -r "service_role" lib/` → leer)
- [ ] Repository nach Secrets durchsuchen (`git log -p | grep -i "eyJ"`)
- [ ] `flutter build apk --release` → APK mit `apktool` öffnen und prüfen, dass keine
      Geheimnisse im Klartext liegen
- [ ] Commit — `chore(security): rls and secret audit`

---

# Meilenstein M8 · Politur und Release

## Task 8.0: Website und Rechtsseiten

> **🔀 Teil A ist jederzeit vorziehbar und sollte früh gemacht werden.** Er hängt an
> keinem App-Code. Wer ihn bis M8 aufschiebt, macht ihn unter Release-Druck – und die
> Store-Formulare verlangen die URLs, *bevor* man einreichen darf.
> **Teil B ist echt blockiert** und kann erst nach Task 8.3/8.4 fertiggestellt werden.

**Hosting:** vorhandenes Hostinger-Abo. Statisches HTML reicht – kein PHP, kein CMS.
EU-Standort wählen (Litauen oder Niederlande) und den AV-Vertrag von Hostinger holen.

### Teil A — sofort machbar

**Dateien:**
- Create: `assets/legal/impressum.md`, `datenschutz.md`, `agb.md`, `nutzungsbedingungen.md`
- Create: `website/index.html`, `datenschutz.html`, `impressum.html`, `agb.html`,
  `nutzungsbedingungen.html`, `account-loeschen.html`, `style.css`
- Create: `tool/gen_website.dart`

**Produziert:** Sechs statische Seiten für Hostinger + die vier Markdown-Rechtstexte, die
**Task 7.2 unverändert weiterverwendet**. Task 7.2 schrumpft dadurch auf „Markdown in der
App rendern und verlinken".

- [x] **Schritt 1: Domain klären**

Prüfen, ob `asm-app.de` frei/vorhanden ist. Falls nicht: Alternative wählen und den Namen
**in allen Docs konsistent ersetzen** (`00-SPEC.md` §7.2, dieser Plan, `CLAUDE.md`).
Die Domain taucht später in Store-Einträgen, Deep Links und im Impressum auf – ein
späterer Wechsel ist teuer.

- [x] **Schritt 2: Rechtstexte als Markdown anlegen — eine Quelle, zwei Ziele**

`assets/legal/*.md` ist die **einzige** Quelle. Website und App rendern beide daraus.
Zwei Kopien pflegen zu müssen ist der sichere Weg zu widersprüchlichen Rechtstexten.

Pflichtinhalte der `nutzungsbedingungen.md` (aus `00-SPEC.md` §7.2 – ohne die lehnt
Apple nach Guideline 1.2 ab):

- Verbotene Artikel: scharfe Waffen, Munition, Heißgaswaffen, entmilitarisierte Waffen,
  Artikel ohne Airsoft-Bezug
- Abgabe von Geräten über 0,5 J nur an Personen ab 18
- F-Kennzeichen-Foto ist Pflicht bei über 0,5 J
- Besitznachweis-Foto ist Pflicht
- Null-Toleranz-Klausel für anstößige Inhalte und missbräuchliches Verhalten
- Beschreibung des Melde- und Abhilfeverfahrens (DSA Art. 16), Reaktion binnen 24 h
- Kontaktstelle mit E-Mail-Adresse

> ⚠️ Die von Sonnet erzeugten Texte sind **Entwürfe zur Anwaltsprüfung**, kein fertiges
> Recht. Als solche kennzeichnen (`<!-- ENTWURF – anwaltlich pruefen -->` oben in jeder
> Datei) und vor dem Release ersetzen.

- [x] **Schritt 3: `tool/gen_website.dart` schreiben**

Liest `assets/legal/*.md`, rendert jede Datei in das HTML-Template und schreibt sie nach
`website/`. Rund 60 Zeilen, verhindert dauerhaftes Auseinanderlaufen von App und Website.
Aufruf: `dart run tool/gen_website.dart`.

- [x] **Schritt 4: `website/style.css` aus den Design-Tokens**

Dieselben Farben und Schriften wie die App – Website und App sollen erkennbar
zusammengehören. Werte aus `01-DESIGN-SYSTEM.md` Abschnitt 2 und 3 als CSS-Variablen:

```css
:root {
  --bg: #171A18;  --surface: #222622;  --border: #3A403A;
  --brand-bright: #7D8B6A;  --text-primary: #E8EAE5;  --text-secondary: #A8ADA4;
}
```

Schriften **lokal einbinden** (`website/fonts/`), nicht über die Google-Fonts-CDN –
gleiche DSGVO-Begründung wie **G12** in der App.

- [x] **Schritt 5: `index.html` — Landingpage**

Zweck ist nicht Marketing, sondern: Store-Pflichtfeld „Support-URL" bedienen und
Vertrauen schaffen. Inhalt: Logo-Lockup, ein Satz was ASM ist, Store-Badges (später),
drei Screenshots, Links auf alle Rechtsseiten, `support@asm-app.de`.

**Kein Kontaktformular.** Sobald eines existiert, verarbeitest du auf Hostinger
personenbezogene Daten und brauchst dafür eigene Datenschutz-Angaben. Eine
`mailto:`-Adresse reicht und ist rechtlich sauberer.

- [x] **Schritt 6: `account-loeschen.html` — Google-Play-Pflichtseite**

Google verlangt eine **öffentlich erreichbare Web-URL** zur Löschung; die In-App-Löschung
aus Task 2.6 allein genügt nicht. Die Seite muss beschreiben:
welche Daten gelöscht werden, welche wie lange aufbewahrt werden und wie man die Löschung
ohne installierte App anstößt (E-Mail an `support@`).

> ⚠️ **Schritt 7 und 8 kann Sonnet nicht ausführen** — beides braucht Zugriff auf den
> Hostinger-Account des Nutzers (Postfach anlegen, Dateien hochladen). Bleibt offen bis
> der Nutzer das selbst macht.

- [ ] **Schritt 7: E-Mail-Postfach einrichten**

`support@asm-app.de` bei Hostinger anlegen. Wird gebraucht für: Impressum, Store-Kontakt,
Apple-Guideline 1.2 („veröffentlichte Kontaktmöglichkeit"), Löschanfragen, DSA-Kontaktstelle.

- [ ] **Schritt 8: Hochladen und prüfen**

Per Hostinger-Dateimanager oder FTP nach `public_html/`. Danach jede URL im Browser öffnen –
HTTPS aktiv, kein Zertifikatsfehler, keine Weiterleitung.

- [x] **Schritt 9: Commit** — `feat(web): add landing page and legal documents` (`b7741fb`)

### Teil B — blockiert bis Task 8.3 / 8.4

Deep Links (`https://asm-app.de/listing/<id>` öffnet die App) brauchen zwei Dateien, die
erst mit den echten Signaturdaten befüllt werden können.

- [ ] **`website/.well-known/assetlinks.json`** — braucht den **SHA-256-Fingerprint des
      Release-Keystores** aus Task 8.4:

```bash
keytool -list -v -keystore upload-keystore.jks -alias upload | grep SHA256
```

- [ ] **`website/.well-known/apple-app-site-association`** — braucht die **Apple Team ID**
      aus Task 8.3. Format: JSON, aber **ohne** `.json`-Dateiendung.

- [ ] **`.htaccess` für den korrekten Content-Type** — der häufigste Grund, warum
      iOS-Deep-Links „unerklärlich" nicht funktionieren:

```apache
<Files "apple-app-site-association">
  ForceType application/json
</Files>
```

- [ ] **Prüfen:** Beide Dateien über HTTPS erreichbar, ohne Weiterleitung, korrekter
      Content-Type (`curl -I`). Danach Deep Link auf einem echten Gerät testen.
- [ ] **Commit** — `feat(web): add deep link association files`

---

## Task 8.1: Qualitätsdurchgang
- [ ] Alle 24 Screens durchgehen: Ladezustand, Fehlerzustand, leerer Zustand vorhanden?
- [ ] Textskalierung auf 200 % stellen — nichts überläuft, nichts wird abgeschnitten
- [ ] TalkBack (Android) und VoiceOver (iOS) durch die Hauptflows
- [ ] Flugmodus-Test auf jedem Screen
- [ ] Langsame Verbindung simulieren (Android Emulator → Network → Edge)
- [ ] Kaltstart messen, Ziel unter 2,5 s
- [ ] `flutter build apk --analyze-size` — Ziel unter 30 MB
- [ ] Commit — `fix: polish loading, error and empty states`

## Task 8.2: Store-Assets
- [ ] Logo als SVG (Design-System 7.1), daraus App-Icon 1024×1024
- [ ] `flutter_launcher_icons` und `flutter_native_splash` konfigurieren und ausführen
- [ ] 6 Screenshots je Plattform mit Textoverlay
- [ ] Store-Beschreibung, Kurzbeschreibung, Keywords
- [ ] Datenschutz-URL, Support-URL, Account-Löschung-URL
- [ ] Google Play "Datensicherheit"-Formular ausfüllen, Apple "Privacy Nutrition Labels"
- [ ] Commit — `chore: add app icons, splash and store assets`

## Task 8.3: iOS-Setup und erster Build
- [ ] Apple Developer Account (99 USD/Jahr), Bundle-ID `de.asmapp.asm`
- [ ] Signing, Provisioning, APNs-Key für FCM
- [ ] `Info.plist`: `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription` —
      **auf Deutsch und konkret** formulieren ("ASM braucht Zugriff auf deine Fotos,
      damit du Bilder zu deinem Inserat hinzufügen kannst.") — vage Texte werden abgelehnt
- [ ] `flutter build ipa` → TestFlight
- [ ] **App-Review-Notizen vorbereiten** (siehe `00-SPEC.md` §7.2): Airsoft = Sportgerät
      nach deutschem Recht unter 7,5 J, F-Kennzeichen, 18+-Gate, keine Zahlungsabwicklung.
      Testkonto mit Zugangsdaten beilegen.
- [ ] Commit — `chore(ios): configure signing and first testflight build`

## Task 8.4: Android-Release
- [ ] Play Console (25 USD einmalig), Keystore erzeugen und **sicher sichern**
      (verloren = App kann nie wieder aktualisiert werden)
- [ ] `key.properties` (gitignored), Release-Signing in `build.gradle.kts`
- [ ] `flutter build appbundle --release --dart-define-from-file=env/prod.json`
- [ ] Internal Testing Track, 5 Tester
- [ ] Commit — `chore(android): configure release signing`

## Task 8.5: Beta und Launch
- [ ] 15–25 Tester aus der Airsoft-Community (ASVZ-Forum, Team-Discords) einladen
- [ ] Feedback-Kanal einrichten
- [ ] Sentry beobachten, crash-freie Sessions über 99,5 %
- [ ] **Kaltstart-Problem beachten:** Ein leerer Marktplatz ist wertlos. Vor dem Launch
      50–100 echte Inserate einsammeln (befreundete Teams bitten, ihre Verkäufe zuerst
      hier einzustellen). Ohne Inventar kommt niemand wieder.
- [ ] Produktions-Release

---

## Test-Strategie

| Ebene | Umfang | Was |
|---|---|---|
| **Unit** | ~60 % der Tests | Validatoren, Formatter, Filter-Logik, Modell-Mapping, PLZ-Lookup |
| **Repository** | ~20 % | Mit `mocktail`-Mock des `SupabaseClient`: richtige Parameter, richtiges Mapping, Fehlerübersetzung |
| **Widget** | ~15 % | Kern-Widgets in allen Zuständen, Formularvalidierung, leere Zustände |
| **Integration** | ~5 % | Ein Ende-zu-Ende-Test: Registrieren → Inserat anlegen → suchen → finden → anschreiben |
| **SQL** | manuell, dokumentiert | RLS-Policies und Constraints in `docs/DB-TESTS.md` mit erwarteten Ergebnissen |

**Verbindlich:** Kein Task gilt als fertig ohne mindestens einen Test, der ohne die
Implementierung fehlschlägt.

---

## Definition of Done (pro Task)

1. Test existiert und ist ohne die Implementierung rot
2. Implementierung macht ihn grün
3. `flutter analyze` → 0 Fehler, 0 Warnungen
4. `dart format .` angewendet
5. Auf einem echten Gerät angesehen (bei UI-Tasks)
6. Deutsche Texte sind in `app_de.arb`, nicht im Widget
7. Keine Farb-/Größen-Literale
8. Commit im Conventional-Commits-Format

---

## Aufwandsschätzung

Realistische Größenordnung mit Sonnet als Umsetzer und dir als Reviewer,
bei etwa 10–15 Stunden pro Woche:

| Meilenstein | Aufwand |
|---|---|
| M0 Fundament (inkl. Toolchain-Installation) | 1 Woche |
| M1 Backend | 1–1,5 Wochen |
| M2 Auth & Profil | 1,5 Wochen |
| M3 Feed & Suche | 1,5 Wochen |
| M4 Inserat erstellen | 2–2,5 Wochen |
| M5 Detail & Favoriten | 1 Woche |
| M6 Chat & Push | 2 Wochen |
| M7 Moderation & Recht | 1 Woche |
| M8 Politur & Release | 2–3 Wochen (Store-Reviews dauern) |
| **Gesamt** | **13–16 Wochen** |

Die häufigsten Verzögerungen: iOS-Signing (rechne mit 2–3 Tagen beim ersten Mal),
App-Store-Review-Runden, und Push-Benachrichtigungen auf iOS.
