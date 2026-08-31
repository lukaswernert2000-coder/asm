import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SizedBox(height: 300, child: child)));

void main() {
  testWidgets('ohne Bilder: zeigt nur den Platzhalter, keinen Indikator', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(ListingGallery(imageUrls: const [], onImageTap: (_) {})),
    );
    await tester.pump();

    expect(find.byType(AsmNetworkImage), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('zeigt so viele Indikator-Punkte wie Bilder', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListingGallery(
          imageUrls: const ['a.jpg', 'b.jpg', 'c.jpg'],
          onImageTap: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('galleryDot-0')), findsOneWidget);
    expect(find.byKey(const Key('galleryDot-1')), findsOneWidget);
    expect(find.byKey(const Key('galleryDot-2')), findsOneWidget);
  });

  testWidgets('Wischen wechselt die Seite', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListingGallery(
          imageUrls: const ['a.jpg', 'b.jpg'],
          onImageTap: (_) {},
        ),
      ),
    );
    await tester.pump();

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    // Kein pumpAndSettle: die Seiten zeigen Shimmer, waehrend
    // AsmNetworkImage laedt, eine Dauer-Animation, auf die pumpAndSettle nie
    // zurueckkehrt (gleiches Problem wie in listing_card_test.dart). Ein
    // fester Pump ueber die PageView-Wechselanimation reicht.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    final dot1 = tester.widget<Container>(
      find.byKey(const Key('galleryDot-1')),
    );
    final decoration = dot1.decoration! as BoxDecoration;
    expect(decoration.color, AsmColors.brandBright);
  });

  testWidgets('Tap auf ein Bild ruft onImageTap mit dem Index auf', (
    tester,
  ) async {
    int? tappedIndex;
    await tester.pumpWidget(
      _wrap(
        ListingGallery(
          imageUrls: const ['a.jpg', 'b.jpg'],
          onImageTap: (index) => tappedIndex = index,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(PageView));

    expect(tappedIndex, 0);
  });
}
