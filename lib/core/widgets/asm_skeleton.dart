import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

enum _SkeletonLayout { listingGrid, listingList, detail }

/// Ladeskelett. Genau drei Layouts, siehe 01-DESIGN-SYSTEM.md Abschnitt 5.8.
/// Kein `CircularProgressIndicator` als Ganzseiten-Ladeanzeige (G14).
class AsmSkeleton extends StatelessWidget {
  const AsmSkeleton.listingGrid({super.key})
    : _layout = _SkeletonLayout.listingGrid;
  const AsmSkeleton.listingList({super.key})
    : _layout = _SkeletonLayout.listingList;
  const AsmSkeleton.detail({super.key}) : _layout = _SkeletonLayout.detail;

  final _SkeletonLayout _layout;

  static Widget _block({
    required double height,
    double? width,
    double radius = AsmRadius.sm,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AsmColors.shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _card() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: _block(height: double.infinity, radius: AsmRadius.md),
        ),
        const SizedBox(height: AsmSpacing.xs),
        _block(height: 14),
        const SizedBox(height: AsmSpacing.xxs),
        _block(width: 96, height: 14),
      ],
    );
  }

  Widget _listingGrid() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AsmSpacing.sm,
      crossAxisSpacing: AsmSpacing.sm,
      childAspectRatio: 0.72,
      children: List.generate(6, (_) => _card()),
    );
  }

  Widget _listingList() {
    return ListView.separated(
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: AsmSpacing.sm),
      itemBuilder: (context, _) => SizedBox(
        height: 112,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _block(width: 112, height: 112, radius: AsmRadius.md),
            const SizedBox(width: AsmSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _block(height: 16),
                  const SizedBox(height: AsmSpacing.xs),
                  _block(width: 120, height: 16),
                  const SizedBox(height: AsmSpacing.xs),
                  _block(width: 160, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail() {
    return ListView(
      padding: const EdgeInsets.all(AsmSpacing.md),
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: _block(height: double.infinity, radius: AsmRadius.lg),
        ),
        const SizedBox(height: AsmSpacing.md),
        _block(height: 22),
        const SizedBox(height: AsmSpacing.xs),
        _block(width: 140, height: 22),
        const SizedBox(height: AsmSpacing.lg),
        _block(height: 14),
        const SizedBox(height: AsmSpacing.xxs),
        _block(height: 14),
        const SizedBox(height: AsmSpacing.xxs),
        _block(width: 200, height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = switch (_layout) {
      _SkeletonLayout.listingGrid => _listingGrid(),
      _SkeletonLayout.listingList => _listingList(),
      _SkeletonLayout.detail => _detail(),
    };

    return Shimmer.fromColors(
      baseColor: AsmColors.shimmerBase,
      highlightColor: AsmColors.shimmerHi,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}
