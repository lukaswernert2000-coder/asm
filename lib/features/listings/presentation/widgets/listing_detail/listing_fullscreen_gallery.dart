import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

/// Vollbild-Galerie (eigener Screen im Inventar, 01-DESIGN-SYSTEM.md
/// Abschnitt 9). Pinch-Zoom via Flutters eingebautem [InteractiveViewer] --
/// kein zusaetzliches Paket.
class ListingFullscreenGallery extends StatefulWidget {
  const ListingFullscreenGallery({
    required this.imageUrls,
    this.initialIndex = 0,
    super.key,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<ListingFullscreenGallery> createState() =>
      _ListingFullscreenGalleryState();
}

class _ListingFullscreenGalleryState extends State<ListingFullscreenGallery> {
  late final _controller = PageController(initialPage: widget.initialIndex);
  late int _page = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AsmColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Semantics(
            label: 'Schließen',
            button: true,
            child: IconButton(
              key: const Key('fullscreenGalleryClose'),
              icon: const Icon(LucideIcons.x, color: AsmColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
        title: widget.imageUrls.length > 1
            ? Text(
                '${_page + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(color: AsmColors.textPrimary),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.imageUrls.length,
        onPageChanged: (page) => setState(() => _page = page),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(AsmSpacing.md),
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: widget.imageUrls[index],
              fit: BoxFit.contain,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: AsmColors.shimmerBase,
                highlightColor: AsmColors.shimmerHi,
                child: Container(color: AsmColors.shimmerBase),
              ),
              errorWidget: (context, url, error) => const Icon(
                LucideIcons.imageOff,
                size: 32,
                color: AsmColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
