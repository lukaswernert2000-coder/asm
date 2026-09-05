# ASM · Website-Architektur (Marktplatz + Teaser)

**Status:** Entwurf, zur Freigabe
**Stand:** 2026-09-05

---

## 1. Ziel

Die Domain `asm-app.de` (aktuell nur statische Rechtstexte, gehostet auf Hostinger) wird zu
einer echten Website ausgebaut, die denselben Supabase-Datenbestand liest wie die App.
Primäres Ziel ist **Reichweite über Google**: einzelne Inserate sollen crawlbar/indexierbar
sein, damit z. B. eine Suche nach einem bestimmten Airsoft-Gewehr über die Website zum
Marktplatz führt. Desktop-Komfort für bestehende Nutzer ist ein Nebeneffekt, nicht der
Auslöser dieser Entscheidung.

Die Website ist **zweiphasig**, weil sie vor dem eigentlichen App-Launch live gehen muss –
zu einem Zeitpunkt, an dem es noch keine echten Inserate gibt. Die beiden Phasen sind
**bewusst unterschiedliche Tech-Stacks**, kein gemeinsames Projekt:

- **Phase 0 (jetzt):** die bestehende statische `website/`-Seite wird zum Teaser ausgebaut
  (reines HTML, kein neues Tooling).
- **Phase 1 (ab App-Launch):** eine neue Next.js/Node.js-Anwendung ersetzt sie durch die
  volle Marktplatz-Website.

Was zwischen den Phasen stabil bleiben muss, ist nicht der Code, sondern **Domain und
URLs** – dort hängt der SEO-Wert. Siehe Abschnitt 4.

## 2. Phase 0 – Teaser (jetzt)

**Befund im Repo:** `website/index.html` ist bereits handgeschrieben (nicht generiert) und
inhaltlich schon nah an einem Teaser – Hero, vier Feature-Cards, ein Hinweis "ASM befindet
sich aktuell im Aufbau". `tool/gen_website.dart` generiert ausschließlich die vier
Rechtstexte (`impressum.html`, `datenschutz.html`, `agb.html`,
`nutzungsbedingungen.html`) aus `assets/legal/*.md` – `index.html` und
`account-loeschen.html` fasst der Generator nicht an.

**Also keine neue Infrastruktur, sondern eine gezielte Erweiterung:**
- `website/index.html`: Feature-Cards um Screenshots ergänzen (aus dem Emulator
  eingefangen, siehe Abschnitt 6), den "im Aufbau"-Hinweis von einer Randnotiz zu einem
  deutlich sichtbaren "App erscheint bald"-Element hochziehen (z. B. direkt unter dem Hero).
- Rechtsseiten unverändert über `tool/gen_website.dart` – bleiben Pflicht, unabhängig vom
  App-Status.
- Hosting/Deploy unverändert: weiterhin die bestehende statische Auslieferung auf Hostinger
  (aktuell manueller Upload). Automatisierung davon ist ein separates, optionales Thema,
  nicht Teil dieser Spec.
- **`account-loeschen.html` bleibt unter genau diesem Pfad** – falls diese URL schon bei
  Google Play / App Store als Pflicht-Link zur Kontolöschung hinterlegt ist, darf sich der
  Pfad beim späteren Wechsel zu Phase 1 nicht ändern (siehe Abschnitt 4).

**SEO-Erwartung realistisch halten:** rankt für Markenname und generische Begriffe
("Airsoft Marktplatz", "Airsoft gebraucht kaufen/verkaufen"). Long-Tail-Produktsuchen (die
eigentliche Stärke von Phase 1) sind erst mit echten Inseraten möglich.

## 3. Phase 1 – Marktplatz (ab App-Launch)

**Architektur:**
- **Next.js** (App Router), liest **direkt gegen Supabase** (Anon-Key,
  `@supabase/supabase-js` serverseitig in Server Components) – kein eigenes Backend, kein
  API-Layer, kein `service_role`-Key. Dieselbe RLS wie die App gilt automatisch mit.
- **Hosting: Hostinger Business** (bereits vorhandener Tarif), über die native
  Node.js-App-Funktion in hPanel. Gegen Hostingers eigene Doku bestätigt: Business-Plan
  unterstützt Node-Apps, Next.js wird automatisch erkannt, SSR/ISR/API-Routen funktionieren
  ohne Einschränkung. Keine zusätzlichen Hosting-Kosten.
- **Deploy:** Hostingers GitHub-Integration – Push auf den verbundenen Branch löst
  automatisch Build + Deploy aus. Ein schlanker CI-Job (nur getriggert bei Änderungen unter
  `web/`) führt vorher `next build` aus. Berührt die bestehende Flutter-CI nicht.
- **Repo:** neuer Ordner `web/` im bestehenden Repo (Monorepo), neben `lib/`, `android/`,
  `ios/`, `supabase/`.
- Die Rechtstexte wandern in dieses Projekt (aus denselben `assets/legal/*.md`, die auch
  die App nutzt) – eine Quelle, ein Generator statt zwei getrennter Systeme.

**Neue Routen:**
- `/kategorie/[slug]` – Kategorie-Browse. Filter (Preis, Zustand, Antriebsart) als
  URL-Query-Parameter (SEO-/bookmark-freundlich).
- `/suche?q=...` – Volltextsuche.
- `/inserat/[id]` – Detailseite mit vollen Meta-Tags + JSON-LD (`schema.org/Product` +
  `Offer`; `availability` aus `status` abgeleitet: `active`→`InStock`,
  `reserved`→`LimitedAvailability`, `sold`→`SoldOut`).
- `/` zeigt jetzt echten Marktplatz-Inhalt (neueste Inserate, Kategorien) statt Teaser.

**Datenzugriff:**
- Kategorie- und Suchseiten rufen **`search_listings()`** auf – dieselbe Postgres-Funktion,
  die die App nutzt. Keine zweite Filterlogik.
- Detailseiten lesen direkt aus `listings` + `listing_images` + `categories`.
- **Sicherheitsregel:** Die Detailseiten-Bildergalerie filtert zwingend auf
  `listing_images.kind = 'photo'`. Die Kinds `f_marking` und `ownership_proof` dürfen auf
  der Website nie angezeigt werden.
- Verkaufte Inserate (`status = 'sold'`) bleiben erreichbar (RLS erlaubt das explizit) und
  zeigen ein "Verkauft"-Badge statt Kontakt-Button, statt als 404 Linkwert zu verlieren.
  Nicht-öffentliche Stati liefert RLS für anonyme Anfragen gar nicht erst zurück – "keine
  Zeile gefunden" wird von der Seite als 404 behandelt, keine eigene Statusprüfung nötig.

**Rendering:**
- Detailseiten: ISR, Revalidate 60s.
- Kategorie-/Suchseiten: SSR pro Request (Filter/Pagination variieren pro Aufruf).
- Startseite: ISR, Revalidate ~5 Min.

## 4. Übergang von Phase 0 zu Phase 1

Kein gemeinsamer Code, kein Feature-Flag – die statische Seite wird zu einem noch nicht
festgelegten Zeitpunkt (App-Launch absehbar) durch das Next.js-Projekt **ersetzt**:
Hostinger Node.js-App-Hosting für die Domain einrichten, deployen, die Domain von der
statischen Auslieferung auf die Node-App umstellen.

**Nicht verhandelbar dabei – URL-Stabilität:**
- `/` bleibt `/`.
- Rechtsseiten- und `account-loeschen`-Pfade bleiben erreichbar. Next.js erzeugt standardmäßig
  Pfade ohne `.html` (`/impressum` statt `/impressum.html`) – die alten `.html`-Pfade
  brauchen daher mindestens einen 301-Redirect, **zwingend für `/account-loeschen.html`**,
  falls diese exakte URL bei Google Play / App Store als Kontolöschungs-Link hinterlegt ist
  (vor dem Umstieg prüfen).
- Danach gilt: Backlinks und Google-Vertrauen, die die Teaser-Seite bis dahin gesammelt hat,
  bleiben erhalten, weil Domain und wichtige Pfade gleich bleiben – nur der Inhalt dahinter
  wechselt.

## 5. Fehlerbehandlung (Phase 1)

- Supabase-Anfrage schlägt zur Laufzeit fehl (Netzwerk-Hänger, kurzer Ausfall): Seite zeigt
  einen freundlichen Fallback statt abzustürzen; `sitemap.xml` liefert im Fehlerfall die
  zuletzt bekannte Liste statt einer leeren Sitemap.
- Nicht existierende oder nicht-öffentliche Inserat-ID: Next.js `notFound()` (siehe
  Abschnitt 3 – RLS liefert für nicht-öffentliche Stati ohnehin keine Zeile).

## 6. Testing & Bildmaterial

- **Phase 0:** Screenshots für die Teaser-Seite werden aus dem Emulator eingefangen
  (Browse-, Detail-, Chat-Screen o. ä.).
- **Phase 1:** lokale Entwicklung gegen dasselbe Dev-Supabase-Projekt wie die App
  (`env/dev.json`). CI-Job (GitHub Actions, getriggert nur bei Änderungen unter `web/`):
  `next build` muss grün sein, bevor auf den Auto-Deploy-Branch gemerged wird.

## 7. Vorschlag zur Umsetzungsreihenfolge

Der nächste Schritt (Implementierungsplan) bezieht sich nur auf **Phase 0** – kleine,
in sich geschlossene Erweiterung der bestehenden statischen Seite. Die App selbst ist noch
mitten im MVP (M6/M7, Security-Review offen, kein Test auf echtem Gerät). Phase 1
(Next.js-Projekt) bekommt einen eigenen, späteren Implementierungsplan, sobald der
App-Launch absehbar ist – dann auch mit Detailfragen wie der genauen Hostinger-Konfiguration
für ein Unterverzeichnis (`web/`) statt Repo-Root als Build-Quelle.

## 8. Offene Punkte / bewusst nicht Teil dieser Spec

- **E-Mail-Warteliste auf dem Teaser:** nicht angefragt, daher nicht Teil der Spec. Ließe
  sich bei Bedarf ergänzen (zusätzliche datenschutzrechtliche Pflichten beachten) – eigene
  Entscheidung.
- **Deep-Link von Website in die App** (z. B. `asm://inserat/<id>`, analog zu den
  bestehenden `asm://auth-callback`/`asm://reset-password`-Schemes): sinnvolle spätere
  Ergänzung für Phase 1, kein Blocker für den ersten Wurf.
- **Automatisierung des Phase-0-Deploys** (aktuell manueller Upload zu Hostinger): möglich,
  aber nicht angefragt – separate Entscheidung.
