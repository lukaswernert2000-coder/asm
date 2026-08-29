import 'package:asm/features/moderation/domain/report_reason.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dbValue entspricht den neun festen Gruenden aus Task 1.5', () {
    expect(ReportReason.verbotenerArtikel.dbValue, 'verbotener_artikel');
    expect(ReportReason.keinFKennzeichen.dbValue, 'kein_f_kennzeichen');
    expect(ReportReason.vollautomat.dbValue, 'vollautomat');
    expect(ReportReason.keinBesitznachweis.dbValue, 'kein_besitznachweis');
    expect(ReportReason.betrugsverdacht.dbValue, 'betrugsverdacht');
    expect(ReportReason.falscheKategorie.dbValue, 'falsche_kategorie');
    expect(ReportReason.beleidigung.dbValue, 'beleidigung');
    expect(ReportReason.spam.dbValue, 'spam');
    expect(ReportReason.sonstiges.dbValue, 'sonstiges');
  });
}
