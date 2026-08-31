import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:flutter/material.dart';

/// Bildergalerie der Detailseite: Seitenindikator, Tap ruft [onImageTap] auf
/// (oeffnet die Vollbild-Galerie in der Detailseite). Ohne Bilder nur der
/// Platzhalter aus [AsmNetworkImage] -- kein leerer PageView.
class ListingGallery extends StatefulWidget {
  const ListingGallery({
    required this.imageUrls,
    required this.onImageTap,
    super.key,
  });

  final List<String> imageUrls;
  final void Function(int index) onImageTap;

  @override
  State<ListingGallery> createState() => _ListingGalleryState();
}

class _ListingGalleryState extends State<ListingGallery> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const AspectRatio(
        aspectRatio: 4 / 3,
        child: AsmNetworkImage(path: null),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => widget.onImageTap(index),
              child: AsmNetworkImage(path: widget.imageUrls[index]),
            ),
          ),
        ),
        if (widget.imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: AsmSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.imageUrls.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AsmSpacing.xxs / 2,
                    ),
                    child: Container(
                      key: Key('galleryDot-$i'),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page
                            ? AsmColors.brandBright
                            : AsmColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
