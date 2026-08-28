import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  for (final entry in <String, Widget>{
    'listingGrid': const AsmSkeleton.listingGrid(),
    'listingList': const AsmSkeleton.listingList(),
    'detail': const AsmSkeleton.detail(),
  }.entries) {
    testWidgets('${entry.key} rendert ohne CircularProgressIndicator', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(entry.value));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  testWidgets('nutzt shimmerBase/shimmerHi und 1200ms Periode', (tester) async {
    await tester.pumpWidget(_wrap(const AsmSkeleton.listingGrid()));

    final shimmer = tester.widget<Shimmer>(find.byType(Shimmer));
    final gradient = shimmer.gradient as LinearGradient;
    expect(
      gradient.colors,
      containsAll([AsmColors.shimmerBase, AsmColors.shimmerHi]),
    );
    expect(shimmer.period, const Duration(milliseconds: 1200));
  });
}
