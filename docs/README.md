# ASM – Airsoft Marketplace · Dokumentation

Mobile Marktplatz-App (Android + iOS) für gebrauchte Airsoft-Ausrüstung.
Flutter · Supabase · Riverpod · Dark-First "Tactical Olive"

---

## Wie diese Dokumente zusammenhängen

| Datei | Inhalt | Für wen |
|---|---|---|
| **[00-SPEC.md](00-SPEC.md)** | **Was** gebaut wird: Produktvision, Scope, Kategorie-Taxonomie, Feature-Specs, Recht & Compliance | Dich + Sonnet (Referenz) |
| **[01-DESIGN-SYSTEM.md](01-DESIGN-SYSTEM.md)** | **Wie es aussieht**: Farbtokens, Typografie, Komponenten, fertiger `theme.dart`, Logo-Konzept | Sonnet (Umsetzung) |
| **[02-IMPLEMENTATION-PLAN.md](02-IMPLEMENTATION-PLAN.md)** | **Wie es gebaut wird**: Meilensteine M0–M8, Tasks, SQL-Migrationen, Tests, Commits | Sonnet (Ausführung) ← **Hauptdatei** |
| **[03-ARBEITEN-MIT-SONNET.md](03-ARBEITEN-MIT-SONNET.md)** | Copy-Paste-Prompts, Workflow, typische Fallen | Dich |

**Startpunkt für die Umsetzung:** `02-IMPLEMENTATION-PLAN.md`, Meilenstein M0.
**Startpunkt für dich:** `03-ARBEITEN-MIT-SONNET.md`.

---

## Kurzfassung des Projekts

**Problem:** Airsoft-Spieler in DE handeln gebrauchte Ausrüstung über Forenthreads
(airsoft-verzeichnis.de) und allgemeine Plattformen (Kleinanzeigen), die weder die
rechtlichen Besonderheiten (Joule, F-Kennzeichen, 18+) noch die Fachattribute
(Antriebsart, Hop-Up, Kaliber) kennen. Kleinanzeigen löscht Airsoft-Inserate regelmäßig.

**Lösung:** Eine fachspezifische Marktplatz-App mit Airsoft-nativen Kategorien und
Pflichtfeldern, eingebautem Rechtsrahmen (F-Kennzeichen-Foto, Besitznachweis,
Altersgate) und direktem Käufer↔Verkäufer-Chat.

**MVP-Umfang:** Account, Inserat erstellen mit Fotos, 8 Kategorien mit Unterkategorien,
Suche & Filter, Favoriten, Realtime-Chat, Melden/Blockieren, Rechtstexte.

**Bewusst NICHT im MVP:** Bezahlung/Treuhand, Versandabwicklung, Bewertungen mit
Sternen, Web-Version, Push-Kampagnen, Händler-Shops.

---

## Technologie-Entscheidungen auf einen Blick

| Bereich | Wahl | Warum |
|---|---|---|
| App-Framework | **Flutter (stable)** | Eine Codebase für iOS + Android, sehr gute Doku, Sonnet kann es exzellent |
| Backend | **Supabase** (Postgres + Auth + Storage + Realtime) | Relationale Filter (Preis, Joule, Umkreis) sind in Postgres trivial, in Firestore ein Albtraum. Realtime für Chat inklusive. EU-Region wählbar (DSGVO). |
| State | **Riverpod 2 (+ codegen)** | Weniger Boilerplate als BLoC, compile-safe, sehr gut testbar |
| Routing | **go_router** | Deep Links, Auth-Guards, typisierte Routen |
| Modelle | **freezed + json_serializable** | Immutable Models, `copyWith`, Union-Types für UI-States |
| Push | **Firebase Cloud Messaging** | Einziger praktikabler Weg für iOS+Android Push |
| Fehler-Tracking | **Sentry** | Crash-Reports ab Tag 1, sonst fliegst du blind |
| Tests | `flutter_test` + `mocktail` + `integration_test` | Standard, kein Extra-Setup |

Detaillierte Begründungen und Alternativen: siehe `02-IMPLEMENTATION-PLAN.md`, Abschnitt
"Architektur-Entscheidungen (ADRs)".

---

## Quellen der Kategorie-Recherche

- ASVZ-Marktplatz Hauptkategorien: <https://www.airsoft-verzeichnis.de/index.php?status=forum&sp=28>
- ASVZ-Marktplatz-Regeln (§1–§10, Zustandsstufen, F-Kennzeichen, Besitznachweis): <https://www.airsoft-verzeichnis.de/index.php?status=forum&sp=27>
- Shop-Taxonomie zur Verfeinerung der Unterkategorien: <https://www.begadi.com/airsoftwaffen.html>, <https://www.softairstore.de/>
- Rechtslage DE (0,5 J, F-Kennzeichen, §42a WaffG): <https://airsoftdrop.de/airsoft-regeln-recht-in-deutschland-joule-f-kennzeichen-transport/>

> ⚠️ Die Rechtshinweise in diesen Dokumenten sind Recherche-Ergebnisse, keine Rechtsberatung.
> Vor dem Store-Release **muss** ein Anwalt für IT-/Waffenrecht über AGB, Datenschutzerklärung
> und das Compliance-Konzept schauen. Siehe `00-SPEC.md` §7.
