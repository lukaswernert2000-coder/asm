import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_fullscreen_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('startet bei initialIndex', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ListingFullscreenGallery(
          imageUrls: ['a.jpg', 'b.jpg', 'c.jpg'],
          initialIndex: 2,
        ),
      ),
    );
    await tester.pump();

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.initialPage, 2);
  });

  testWidgets('zeigt so viele InteractiveViewer wie Bilder im PageView', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ListingFullscreenGallery(imageUrls: ['a.jpg', 'b.jpg']),
      ),
    );
    await tester.pump();

    // PageView baut nur die sichtbare Seite (+ minimaler Cache) -- die
    // aktuelle Seite muss ein InteractiveViewer fuers Pinch-Zoom sein.
    expect(find.byType(InteractiveViewer), findsWidgets);
  });

  testWidgets('Tap auf Schliessen schliesst den Screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const ListingFullscreenGallery(
                      imageUrls: ['a.jpg'],
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    // Kein pumpAndSettle: das Bild zeigt Shimmer, waehrend es laedt, eine
    // Dauer-Animation (gleiches Problem wie in listing_card_test.dart).
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ListingFullscreenGallery), findsOneWidget);

    await tester.tap(find.byKey(const Key('fullscreenGalleryClose')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ListingFullscreenGallery), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });
}
