# ASM · Geschäftsmodell

**Status:** Kein Teil des MVP. v1.0 ist vollständig kostenlos und werbefrei.
Dieses Dokument hält fest, **wie** später Geld verdient werden soll, damit die
Entscheidung nicht unter Druck getroffen wird.

**Stand:** 2026-08-30

---

## 1. Die Marktgröße, ehrlich

Der ASVZ-Marktplatz hatte bei der Recherche im August 2026 **9.647 aktive Inserate** —
das ist praktisch die gesamte deutsche Airsoft-Gebrauchtszene an einem Ort. Nicht pro
Monat, sondern insgesamt.

Realistisches Szenario über zwei Jahre: ASM bekommt 30 % davon, also rund 3.000 Inserate
und 3.000–6.000 aktive Nutzer.

**Das ist eine kleine, dichte Nische.** Jedes Modell, das auf Volumen setzt, funktioniert
hier nicht. Umgekehrt: Modelle mit wenigen, gut zahlenden Partnern funktionieren
ausgezeichnet.

> Diese Zahl ist die wichtigste im Dokument. Wer sie ignoriert, baut ein Werbenetzwerk
> für 4.000 Leute.

---

## 2. Die Kostenseite — das erste realistische Ziel ist Kostendeckung

| Posten | Größenordnung |
|---|---|
| Supabase Pro (sobald das Free-Tier gesprengt ist) | 25 $/Monat |
| Storage für Inseratsbilder — **der eigentliche Kostentreiber** | wächst mit dem Bestand |
| Hostinger (Domain + Website) | ~5 €/Monat |
| Apple Developer Program | 99 $/Jahr |
| Google Play Developer | 25 $ einmalig |
| Sentry | Free-Tier reicht lange |
| **Break-even** | **grob 50–80 €/Monat** |

Das sind **zwei bis drei Händler-Accounts**. Nicht mehr. Gewinn ist ein späteres Thema;
„die App trägt sich selbst" ist in Reichweite.

**Kostenbremse einbauen:** Bilder werden vor dem Upload auf 1600 px / 80 % komprimiert
(Task 4.1). Ohne das explodiert der Storage-Posten als Erstes.

---

## 3. Leitprinzip

> **Geld kommt von denen, die kommerziell profitieren — nie von Hobbyisten, die etwas
> loswerden wollen.**

Daraus folgt verbindlich:

- **Suche, Chat, Inserieren, Favoriten und Detailseiten bleiben dauerhaft kostenlos
  und ungedrosselt.** Keine Limits auf aktive Inserate, keine Chat-Beschränkung.
- Bezahlte Funktionen geben einen Vorteil, sie nehmen keinen weg.
- Nichts, was ein Käufer sieht, wird durch Monetarisierung schlechter.

Wenn eine Idee gegen einen dieser Punkte verstößt, wird sie nicht umgesetzt — egal wie
gut die Zahlen aussehen.

---

## 4. Was bewusst nicht gemacht wird: Werbebanner

Der Reflex ist AdMob. Vier Gründe dagegen:

| Grund | Konkret |
|---|---|
| **Erlöse sind vernachlässigbar** | Bei 5.000 Nutzern in einer deutschen Nische: 20–50 €/Monat. Weniger als drei Händler-Accounts, für deutlich mehr Ärger. |
| **DSGVO-Zwang zum Consent-Dialog** | Personalisierte Werbung braucht ein CMP mit TCF-Dialog beim ersten Start. Genau die aufdringliche Hürde, die vermieden werden soll — und das Erste, was jeder Nutzer sieht. |
| **Zerstört das Design** | Ein Bannerslot macht aus einem durchdachten Interface eine Gratis-App. |
| **Kontrollverlust** | Ad-Netzwerke zeigen, was sie wollen. In einer waffennahen App ein Risiko, das sich nicht steuern lässt. |

**Entscheidung: keine Werbenetzwerke, dauerhaft.** Nicht „später mal prüfen".

---

## 5. Die drei Einnahmequellen

### 5.1 Händler-Accounts — die stärkste Quelle

In Deutschland gibt es geschätzt **20–40 relevante Airsoft-Shops** (Begadi, softairstore,
Weekend-Warrior, dazu regionale Läden). Ihnen wird kein Banner verkauft, sondern ein
**Shop-Profil**:

- Logo, Beschreibung, Link zum Shop
- Badge „Gewerblich" (rechtlich ohnehin Pflicht)
- Eigener Bereich für B-Ware, Restposten, Vorführmodelle
- Optional: Hervorhebung in der passenden Kategorie

**Rechnung:** 20 Shops × 30 €/Monat = **600 €/Monat.** An dieser Marktgröße gemessen ist
das viel.

**Warum es nicht aufdringlich ist:** Restposten- und B-Ware-Angebote von Händlern sind
genau das, wonach Spieler suchen. Klar gekennzeichnet, kein Etikettenschwindel.

**Was schon steht:** `profiles.is_commercial`, `commercial_name`, `commercial_address`
sind seit Task 1.2 im Datenmodell. Die Grundlage existiert.

**Der Haken:** Das ist Vertriebsarbeit, keine Feature-Arbeit. Die Shops müssen angerufen
werden. Genau deshalb funktioniert es — Konkurrenz macht das nicht.

### 5.2 Hochschieben (Bumps)

Der Plan sieht „Hochschieben alle 14 Tage" als kostenlose Norm vor (ASVZ §7). Die
naheliegende Erweiterung: **häufiger hochschieben kostet.**

- 1 € pro Bump, oder 5 € für 10 Bumps
- Kostenlose Nutzer behalten die 14-Tage-Regel und verlieren nichts
- Wer zahlt, bekommt einen echten geldwerten Vorteil: schnellerer Verkauf

**Bewusst nicht: „Inserat hervorheben".** In einer Kategorie mit 40 Inseraten ist
Sichtbarkeit kein knappes Gut. Dafür Geld zu nehmen wäre ein Verkauf von Nichts — und
das merken Nutzer.

### 5.3 Supporter-Modell

„ASM Supporter", 3 €/Monat: Abzeichen im Profil, ein paar Bump-Credits, sonst nichts.

Klingt nach wenig, funktioniert in engagierten Szenen aber besser als erwartet — Leute
unterstützen das Projekt, sie kaufen kein Feature. Null Aufdringlichkeit: ein Eintrag in
den Einstellungen.

Zusätzlicher Nutzen: **Es ist der billigste Test, ob überhaupt jemand zahlt.** Deshalb
steht es in der Reihenfolge vor den Händler-Accounts.

---

## 6. Der Store-Cut — der am häufigsten übersehene Punkt

**Digitale Features, die in der App genutzt werden, müssen über In-App-Purchase laufen.**
Apple und Google nehmen davon **15 %** (unter 1 Mio. $ Jahresumsatz, Small Business
Program) bis 30 %.

Das trifft **Bumps und Supporter-Abos voll**. Aus 1 € Bump werden 85 Cent.

**Händler-Abos sind der Ausweg:** B2B-Verträge, per Rechnung außerhalb der App
abgerechnet, Freischaltung serverseitig über ein Flag im Profil. Das ist der
Standardweg (Slack, Dropbox handhaben es so). In der App darf dann aber nicht offensiv
darauf verlinkt werden.

> ⚠️ **Vor der Umsetzung aktuell nachlesen.** Die Regeln zu Verlinkungen auf externe
> Zahlungswege haben sich durch den EU-DMA gelockert, Apple erhebt dafür aber eigene
> Gebühren, und das Feld ändert sich ständig. Nicht auf den Stand dieses Dokuments
> verlassen.

Das ist ein weiterer Grund, warum Händler-Accounts die beste erste Einnahmequelle sind:
**kein Store-Abzug.**

---

## 7. Bewusst verschoben

| Idee | Warum später |
|---|---|
| **Zahlung und Treuhand** | Hier liegt das eigentliche Marktplatz-Geschäft (2–5 % vom Umsatz). Aber sobald Geld über die Plattform fließt, greifen Zahlungsdiensteaufsicht (ZAG), Geldwäschegesetz und Plattform-Meldepflichten. Das ist ein eigenes Unternehmen, kein Feature. Siehe `00-SPEC.md` §3.2. |
| **Spielfelder und Events** | Langfristig womöglich das größere Geschäft als der Marktplatz — Betreiber verkaufen Tickets und würden für Reichweite zahlen. Erst, wenn der Marktplatz trägt. |
| **Affiliate zu Shops** | Die wenigsten deutschen Airsoft-Shops haben Partnerprogramme. Prüfen, wenn die Händler-Gespräche ohnehin laufen. |

---

## 8. Reihenfolge

| Wann | Was | Warum in dieser Reihenfolge |
|---|---|---|
| **v1.0** | Nichts. Kostenlos, werbefrei. | Ihr braucht Inventar und Nutzer, nicht Umsatz. Ein leerer Marktplatz mit Bezahlschranke ist doppelt tot. |
| **v1.1** | Supporter-Modell | Billig zu bauen, testet die Zahlungsbereitschaft überhaupt |
| **v1.2** | Händler-Accounts | Höchster Ertrag, kein Store-Abzug — die Arbeit steckt im Telefonieren |
| **v1.3** | Bumps | Erst sinnvoll, wenn genug Inserate da sind, dass Sichtbarkeit knapp wird |
| **später** | Events, dann ggf. Zahlung | Eigene Entscheidungen mit Anwalt |

---

## 9. Was sich rechtlich ändert, sobald Geld fließt

Das ist kein Detail — es verändert euren Status.

| Thema | Folge |
|---|---|
| **Gewerbeanmeldung** | Spätestens mit der ersten Einnahme. Vorher klären, ob GbR oder UG sinnvoll ist — bei einem Marktplatz mit Haftungsfragen spricht einiges für eine UG. |
| **Umsatzsteuer** | Kleinunternehmerregelung (§19 UStG) greift unter 22.000 € Jahresumsatz — dann keine USt. auf Rechnungen, aber auch kein Vorsteuerabzug. Bei euren Größenordnungen zunächst der einfachere Weg. |
| **AGB erweitern** | Zahlungsbedingungen, Laufzeiten, Kündigung. Die bestehenden AGB aus Task 8.0 decken das nicht ab. |
| **Widerrufsrecht** | 14 Tage für Verbraucher bei digitalen Leistungen (Supporter, Bumps). Für Händler-Verträge (B2B) gilt es nicht. |
| **Rechnungen** | Pflichtangaben nach §14 UStG. Für Händler-Abos braucht ihr einen sauberen Rechnungsprozess. |
| **DAC7** | Meldepflichten für Plattformbetreiber prüfen lassen. Solange ihr keine Transaktionen abwickelt, greift sie voraussichtlich nicht — aber das gehört auf die Anwaltsliste. |

> ⚠️ Wie überall in diesen Dokumenten: Recherche, keine Rechtsberatung. Das Gespräch mit
> dem Anwalt, das ohnehin für AGB und Datenschutz ansteht (`00-SPEC.md` §7), sollte diese
> Punkte gleich mit abdecken. Kostet dann kaum mehr.

---

## 10. Offene Punkte

- [ ] Mit 3–5 Shops **vor** dem Launch sprechen: Wäre ein Shop-Profil für 30 €/Monat
      interessant? Was müsste es können? — Das validiert die stärkste Einnahmequelle,
      bevor eine Zeile Code dafür geschrieben wird.
- [ ] Rechtsform klären (GbR vs. UG)
- [ ] Aktuelle Store-Regeln zu externen Zahlungswegen prüfen (ändert sich häufig)
- [ ] Speicherkosten beobachten, sobald echte Inserate reinkommen — das ist die einzige
      Position, die unkontrolliert wachsen kann
