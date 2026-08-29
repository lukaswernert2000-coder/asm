import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Kachel fuer eine Wurzel-Kategorie im Grid der Startseite.
/// Siehe 01-DESIGN-SYSTEM.md Abschnitt 5.5.
class CategoryTile extends StatefulWidget {
  const CategoryTile({required this.category, required this.onTap, super.key});

  final Category category;
  final VoidCallback onTap;

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: AsmDuration.fast,
        child: Container(
          decoration: BoxDecoration(
            color: _pressed ? AsmColors.surfaceRaised : AsmColors.surface,
            border: Border.all(color: AsmColors.border),
            borderRadius: BorderRadius.circular(AsmRadius.lg),
          ),
          padding: const EdgeInsets.all(AsmSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/categories/${widget.category.icon}.svg',
                width: 32,
                height: 32,
                colorFilter: const ColorFilter.mode(
                  AsmColors.brandBright,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: AsmSpacing.xs),
              Text(
                widget.category.name,
                style: AsmTextStyles.titleS,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
