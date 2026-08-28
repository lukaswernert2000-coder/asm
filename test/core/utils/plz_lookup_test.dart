import 'package:asm/core/utils/plz_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loest eine bekannte PLZ auf', () async {
    final result = await PlzLookup.resolve('76133');
    expect(result?.city, 'Karlsruhe');
    expect(result?.lat, closeTo(49.01, 0.05));
  });

  test('gibt null bei unbekannter PLZ zurueck', () async {
    expect(await PlzLookup.resolve('00000'), isNull);
  });
}
