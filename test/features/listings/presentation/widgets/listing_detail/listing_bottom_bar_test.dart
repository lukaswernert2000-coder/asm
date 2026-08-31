import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('zeigt das Primary-Label und ruft onPrimaryPressed auf', (
    tester,
  ) async {
    var pressed = false;
    await tester.pumpWidget(
      _wrap(
        ListingBottomBar(
          primaryLabel: 'Nachricht schreiben',
          onPrimaryPressed: () => pressed = true,
          isFavorited: false,
          onFavoriteToggle: () {},
          onShare: () {},
        ),
      ),
    );

    expect(find.text('Nachricht schreiben'), findsOneWidget);
    await tester.tap(find.text('Nachricht schreiben'));
    expect(pressed, isTrue);
  });

  testWidgets('Herz zeigt gefuellt bei isFavorited und ruft Toggle auf', (
    tester,
  ) async {
    var toggled = false;
    await tester.pumpWidget(
      _wrap(
        ListingBottomBar(
          primaryLabel: 'Nachricht schreiben',
          onPrimaryPressed: () {},
          isFavorited: true,
          onFavoriteToggle: () => toggled = true,
          onShare: () {},
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(LucideIcons.heart));
    expect(icon.color, AsmColors.danger);
    await tester.tap(find.byIcon(LucideIcons.heart));
    expect(toggled, isTrue);
  });

  testWidgets('Herz ist neutral eingefaerbt ohne isFavorited', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ListingBottomBar(
          primaryLabel: 'Nachricht schreiben',
          onPrimaryPressed: () {},
          isFavorited: false,
          onFavoriteToggle: () {},
          onShare: () {},
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(LucideIcons.heart));
    expect(icon.color, isNot(AsmColors.danger));
  });

  testWidgets('Teilen ruft onShare auf', (tester) async {
    var shared = false;
    await tester.pumpWidget(
      _wrap(
        ListingBottomBar(
          primaryLabel: 'Nachricht schreiben',
          onPrimaryPressed: () {},
          isFavorited: false,
          onFavoriteToggle: () {},
          onShare: () => shared = true,
        ),
      ),
    );

    await tester.tap(find.byIcon(LucideIcons.share2));
    expect(shared, isTrue);
  });
}
