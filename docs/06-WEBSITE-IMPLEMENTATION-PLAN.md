# ASM Website Phase 0 (Teaser) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Die bestehende statische `website/`-Landingpage um echte App-Screenshots und einen
deutlich sichtbaren "App erscheint bald"-Hinweis erweitern, bevor die App live geht.

**Architecture:** Reine Erweiterung der bestehenden statischen HTML/CSS-Seite – keine neue
Infrastruktur, kein Node.js, kein Build-Schritt außer dem bereits existierenden
`tool/gen_website.dart` für die (hier unveränderten) Rechtsseiten.

**Tech Stack:** HTML/CSS (bestehendes `website/`-Verzeichnis), Python 3 + Pillow (bereits
installiert, `12.3.0`) zur Bildnachbearbeitung, ADB für die Screenshot-Aufnahme aus dem
Android-Emulator.

**Spec:** [`docs/05-WEBSITE-SPEC.md`](05-WEBSITE-SPEC.md), Abschnitt 2 ("Phase 0 – Teaser").

## Global Constraints

- Alle sichtbaren Texte auf Deutsch (CLAUDE.md, harte Regeln).
- Keine neuen Farb-/Abstands-Literale in `website/style.css` – ausschließlich die
  bestehenden CSS-Variablen (`--bg`, `--surface`, `--border`, `--brand*`, `--text-*`,
  `--warning`, `--space-*`, `--radius-*`) verwenden, siehe Kommentar am Kopf der Datei
  ("dieselben Tokens wie lib/core/theme/").
- `website/impressum.html`, `datenschutz.html`, `agb.html`, `nutzungsbedingungen.html`,
  `account-loeschen.html` und `tool/gen_website.dart` **nicht anfassen** – außerhalb des
  Scopes von Phase 0 (Spec Abschnitt 2/4).
- Keine neuen Abhängigkeiten/Build-Tools einführen (Spec Abschnitt 1: Phase 0 bleibt reines
  HTML).

---

## Task 1: App-Screenshots einfangen und für die Website aufbereiten

**Files:**
- Create: `website/img/screenshot-start.png`
- Create: `website/img/screenshot-listing.png`
- Create: `website/img/screenshot-chats.png`

**Interfaces:**
- Produces: drei PNG-Dateien unter `website/img/`, jeweils 360px breit (Höhe proportional),
  fertig für die Einbindung in Task 2.

- [ ] **Schritt 1: Prüfen, ob der Emulator gerade für etwas anderes in Benutzung ist**

  Ein laufender Emulator kann Teil einer anderen, gerade aktiven Session sein (z. B. ein
  Test nach einem Security-Fix). Vor jeder Navigation erst den aktuellen Zustand ansehen,
  um nichts zu unterbrechen:

  ```bash
  adb devices
  adb exec-out screencap -p > .tmp-current-state.png
  ```

  Screenshot ansehen (z. B. über den Read-Tool-Weg dieser Session). Zeigt der Screen
  Hinweise auf eine laufende Testsitzung (z. B. frisch angelegte Test-Chats/-Daten, ein
  Formular mitten in der Bearbeitung)? Falls ja: mit dem Nutzer abstimmen, ob der Emulator
  frei ist, oder einen zweiten Emulator starten (`flutter emulators` zum Auflisten,
  `flutter emulators --launch <id>` zum Starten) statt den bestehenden Zustand zu verlassen.
  `.tmp-current-state.png` danach löschen.

- [ ] **Schritt 2: App im sauberen Zustand auf dem (bestätigt freien) Emulator starten**

  ```bash
  flutter run --dart-define-from-file=env/dev.json -d emulator-5554
  ```

  Mit einem Test-Account einloggen, der mindestens ein Inserat mit Foto sichtbar hat (im
  Dev-Supabase-Projekt existieren aus früheren Sessions bereits Test-Inserate). Der
  Start-Tab (unterste Navigationsleiste, Label "Start") zeigt die Kategorie-Übersicht.

- [ ] **Schritt 3: Screenshot "Start" (Kategorie-Übersicht) einfangen**

  Sicherstellen, dass der "Start"-Tab aktiv ist, dann:

  ```bash
  mkdir -p .tmp-screenshots
  adb exec-out screencap -p > .tmp-screenshots/start-raw.png
  ```

- [ ] **Schritt 4: Screenshot "Inserat-Detail" einfangen**

  Auf ein Inserat mit Foto tippen (Route `/listing/:id`), dann:

  ```bash
  adb exec-out screencap -p > .tmp-screenshots/listing-raw.png
  ```

- [ ] **Schritt 5: Screenshot "Chats" einfangen**

  Zum "Chats"-Tab wechseln. Falls die sichtbaren Chats aus einer fremden Testsitzung
  stammen und unprofessionell wirken (z. B. Testnachrichten wie "Test nach Security
  Hardening"), stattdessen mit dem eigenen Test-Account einen kurzen, präsentablen
  Beispiel-Chat anlegen, bevor der Screenshot gemacht wird:

  ```bash
  adb exec-out screencap -p > .tmp-screenshots/chats-raw.png
  ```

- [ ] **Schritt 6: Screenshots auf Web-Größe bringen**

  ```bash
  python -c "
from PIL import Image

names = ['start', 'listing', 'chats']
for name in names:
    img = Image.open(f'.tmp-screenshots/{name}-raw.png')
    target_width = 360
    ratio = target_width / img.width
    target_height = round(img.height * ratio)
    resized = img.resize((target_width, target_height), Image.LANCZOS)
    resized.save(f'website/img/screenshot-{name}.png', optimize=True)
    print(f'website/img/screenshot-{name}.png geschrieben ({target_width}x{target_height})')
"
  ```

- [ ] **Schritt 7: Temporäre Dateien entfernen**

  ```bash
  rm -rf .tmp-screenshots .tmp-current-state.png
  ```

- [ ] **Schritt 8: Visuell prüfen**

  Alle drei Dateien unter `website/img/` öffnen. Prüfen: zeigt echte App-Inhalte (keine
  Absturz-/Fehlerscreens), keine sichtbaren Testdaten-Artefakte, Text lesbar trotz
  Verkleinerung auf 360px Breite.

- [ ] **Schritt 9: Commit**

  ```bash
  git add website/img/screenshot-start.png website/img/screenshot-listing.png website/img/screenshot-chats.png
  git commit -m "feat(website): add app screenshots for teaser landing page"
  ```

---

## Task 2: Screenshot-Sektion und "bald verfügbar"-Hinweis in die Landingpage einbauen

**Files:**
- Modify: `website/index.html`
- Modify: `website/style.css`

**Interfaces:**
- Consumes: `website/img/screenshot-start.png`, `website/img/screenshot-listing.png`,
  `website/img/screenshot-chats.png` (aus Task 1).

- [ ] **Schritt 1: Coming-Soon-Hinweis direkt unter dem Hero einbauen**

  In `website/index.html`, das bestehende `<section class="hero">` so ändern (neue Zeile
  direkt nach `<section class="hero">` einfügen):

  ```html
  <section class="hero">
    <p class="coming-soon-badge">App in Entwicklung — Start für iOS &amp; Android in Kürze</p>
    <h1>Airsoft, endlich mit eigenem Marktplatz</h1>
  ```

  (Der Rest der Section – der `<p>`-Absatz mit der Beschreibung – bleibt unverändert.)

- [ ] **Schritt 2: Screenshot-Sektion einbauen**

  In `website/index.html`, direkt nach der schließenden `</section>` der bestehenden
  `<section class="features">` und vor `<section class="legal-links">` einfügen:

  ```html
  <section class="app-preview">
    <h2>So sieht ASM aus</h2>
    <div class="app-preview-grid">
      <figure>
        <img src="img/screenshot-start.png" alt="Kategorie-Übersicht der ASM-App" loading="lazy">
        <figcaption>Kategorien &amp; Inserate durchstöbern</figcaption>
      </figure>
      <figure>
        <img src="img/screenshot-listing.png" alt="Inserats-Detailansicht der ASM-App" loading="lazy">
        <figcaption>Inserat mit allen Details</figcaption>
      </figure>
      <figure>
        <img src="img/screenshot-chats.png" alt="Chat-Übersicht der ASM-App" loading="lazy">
        <figcaption>Direkt mit Verkäufern chatten</figcaption>
      </figure>
    </div>
  </section>
  ```

- [ ] **Schritt 3: Bestehenden "im Aufbau"-Satz in `.legal-links` entfernen**

  Der Hinweis ist jetzt durch das prominentere `.coming-soon-badge` aus Schritt 1 abgedeckt.
  In `website/index.html`, den `<section class="legal-links">`-Inhalt von:

  ```html
  <section class="legal-links">
    <p>ASM befindet sich aktuell im Aufbau. Für Presse- oder sonstige Anfragen:
      <a href="mailto:support@asm-app.de">support@asm-app.de</a></p>
  </section>
  ```

  zu:

  ```html
  <section class="legal-links">
    <p>Für Presse- oder sonstige Anfragen: <a href="mailto:support@asm-app.de">support@asm-app.de</a></p>
  </section>
  ```

  ändern.

- [ ] **Schritt 4: CSS für Badge und Screenshot-Sektion ergänzen**

  In `website/style.css`, nach dem bestehenden `.feature-card p { ... }`-Block (vor
  `.legal-links`) einfügen:

  ```css
  .coming-soon-badge {
    display: inline-block;
    margin: 0 0 var(--space-lg);
    padding: 6px var(--space-md);
    background: var(--surface);
    border: 1px solid var(--warning);
    border-radius: 999px;
    color: var(--warning);
    font-size: 13px;
    font-weight: 600;
    letter-spacing: 0.3px;
  }

  .app-preview {
    text-align: center;
    max-width: 960px;
    margin: 0 auto var(--space-xxl);
    padding: 0 var(--space-xl);
  }

  .app-preview h2 {
    font-family: "Barlow Condensed", sans-serif;
    font-weight: 700;
    font-size: 28px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: var(--space-xl);
  }

  .app-preview-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: var(--space-lg);
  }

  .app-preview-grid figure {
    margin: 0;
  }

  .app-preview-grid img {
    width: 100%;
    height: auto;
    border-radius: var(--radius-lg);
    border: 1px solid var(--border);
    display: block;
  }

  .app-preview-grid figcaption {
    margin-top: var(--space-sm);
    color: var(--text-secondary);
    font-size: 14px;
  }
  ```

- [ ] **Schritt 5: Lokal servieren und im Browser prüfen**

  ```bash
  npx serve website
  ```

  Über das Browser-Pane-Tool öffnen (Standardport von `serve`, i. d. R. `http://localhost:3000`):
  - Alle drei Screenshots laden ohne 404 (Network-Requests prüfen).
  - Coming-Soon-Badge ist unter dem Hero sichtbar, vor der Überschrift.
  - Auf mobiler Breite (z. B. 375px) bricht das Grid auf eine Spalte um, nichts läuft über
    den Viewport hinaus.
  - Bestehende Navigation zu den Rechtsseiten funktioniert weiterhin unverändert.

- [ ] **Schritt 6: Commit**

  ```bash
  git add website/index.html website/style.css
  git commit -m "feat(website): add coming-soon banner and app preview screenshots"
  ```

---

## Nach diesem Plan – manueller Schritt (nicht Teil der Tasks)

Der Upload des aktualisierten `website/`-Ordners zu Hostinger ist wie bisher ein manueller
Schritt, den nur der Nutzer ausführen kann (kein Zugriff auf die Hosting-Zugangsdaten).
Sonnet kann diesen Schritt nicht selbst ausführen – nach Abschluss von Task 2 den Nutzer
darauf hinweisen.
