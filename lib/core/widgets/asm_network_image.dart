import 'package:asm/core/theme/asm_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

/// Netzwerkbild mit Shimmer-Ladezustand und Icon-Fallback bei Fehler oder
/// fehlendem Pfad. Kein eigener Abschnitt-5-Eintrag — Konvention aus 5.4
/// (ListingCard: "Platzhalter = Shimmer, Fehler = Icon") verallgemeinert.
class AsmNetworkImage extends StatelessWidget {
  const AsmNetworkImage({
    required this.path,
    this.aspectRatio,
    this.radius,
    super.key,
  });

  final String? path;
  final double? aspectRatio;
  final BorderRadius? radius;

  static Widget _placeholder() {
    return Shimmer.fromColors(
      baseColor: AsmColors.shimmerBase,
      highlightColor: AsmColors.shimmerHi,
      period: const Duration(milliseconds: 1200),
      child: Container(color: AsmColors.shimmerBase),
    );
  }

  static Widget _fallback() {
    return const ColoredBox(
      color: AsmColors.surfaceRaised,
      child: Center(
        child: Icon(LucideIcons.imageOff, size: 24, color: AsmColors.textTertiary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPath = path != null && path!.isNotEmpty;

    final content = hasPath
        ? CachedNetworkImage(
            imageUrl: path!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => _placeholder(),
            errorWidget: (context, url, error) => _fallback(),
          )
        : _fallback();

    final clipped = ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: content,
    );

    if (aspectRatio == null) {
      return clipped;
    }
    return AspectRatio(aspectRatio: aspectRatio!, child: clipped);
  }
}
