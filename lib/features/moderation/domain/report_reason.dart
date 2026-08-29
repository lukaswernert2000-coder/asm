/// Feste Meldegruende, siehe 02-IMPLEMENTATION-PLAN.md Task 1.5. Task 7.1
/// baut daraus spaeter das Melde-Sheet mit Freitext; Task 2.5 nutzt dieselben
/// Werte schon fuer eine einfache Melden-Aktion auf dem Fremdprofil.
enum ReportReason {
  verbotenerArtikel,
  keinFKennzeichen,
  vollautomat,
  keinBesitznachweis,
  betrugsverdacht,
  falscheKategorie,
  beleidigung,
  spam,
  sonstiges,
}

extension ReportReasonDb on ReportReason {
  String get dbValue => switch (this) {
    ReportReason.verbotenerArtikel => 'verbotener_artikel',
    ReportReason.keinFKennzeichen => 'kein_f_kennzeichen',
    ReportReason.vollautomat => 'vollautomat',
    ReportReason.keinBesitznachweis => 'kein_besitznachweis',
    ReportReason.betrugsverdacht => 'betrugsverdacht',
    ReportReason.falscheKategorie => 'falsche_kategorie',
    ReportReason.beleidigung => 'beleidigung',
    ReportReason.spam => 'spam',
    ReportReason.sonstiges => 'sonstiges',
  };
}
