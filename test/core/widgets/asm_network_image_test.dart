import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('path == null zeigt das Fallback-Icon ohne CachedNetworkImage', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const AsmNetworkImage(path: null)));

    expect(find.byType(CachedNetworkImage), findsNothing);
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 24);
    expect(icon.color, AsmColors.textTertiary);
  });

  testWidgets('gueltiger path baut CachedNetworkImage mit passendem imageUrl', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AsmNetworkImage(path: 'https://example.com/bild.jpg'),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, 'https://example.com/bild.jpg');
  });

  testWidgets(
    'placeholder-Builder liefert den Shimmer aus shimmerBase/shimmerHi',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AsmNetworkImage(path: 'https://example.com/bild.jpg'),
        ),
      );

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      final placeholderWidget = image.placeholder!(
        tester.element(find.byType(CachedNetworkImage)),
        'https://example.com/bild.jpg',
      );

      await tester.pumpWidget(_wrap(placeholderWidget));
      final shimmer = tester.widget<Shimmer>(find.byType(Shimmer));
      final gradient = shimmer.gradient as LinearGradient;
      expect(
        gradient.colors,
        containsAll([AsmColors.shimmerBase, AsmColors.shimmerHi]),
      );
    },
  );

  testWidgets('errorWidget-Builder liefert dasselbe Fallback-Icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AsmNetworkImage(path: 'https://example.com/bild.jpg'),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    final errorWidget = image.errorWidget!(
      tester.element(find.byType(CachedNetworkImage)),
      'https://example.com/bild.jpg',
      Exception('boom'),
    );

    await tester.pumpWidget(_wrap(errorWidget));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 24);
    expect(icon.color, AsmColors.textTertiary);
  });

  testWidgets('aspectRatio und radius werden angewendet', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AsmNetworkImage(
          path: 'https://example.com/bild.jpg',
          aspectRatio: 4 / 3,
          radius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );

    final aspect = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(aspect.aspectRatio, 4 / 3);

    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clip.borderRadius, const BorderRadius.all(Radius.circular(12)));
  });
}
