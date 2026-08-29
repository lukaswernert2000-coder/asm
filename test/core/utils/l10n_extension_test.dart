import 'package:asm/core/utils/l10n_extension.dart';
import 'package:asm/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('context.l10n liest generierte Strings', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('de')],
        locale: const Locale('de'),
        home: Builder(
          builder: (context) => Text(context.l10n.appTitle),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ASM'), findsOneWidget);
  });
}
