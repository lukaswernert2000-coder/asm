import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';

const _collapsedMaxLines = 6;

/// Beschreibungstext, der ab 6 Zeilen abschneidet und "Mehr anzeigen"
/// anbietet (Task 5.1). Der Button erscheint nur, wenn der Text bei der
/// verfuegbaren Breite tatsaechlich ueber 6 Zeilen ginge.
class ExpandableDescription extends StatefulWidget {
  const ExpandableDescription({required this.text, super.key});

  final String text;

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: AsmTextStyles.bodyM),
          maxLines: _collapsedMaxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: AsmTextStyles.bodyM,
              maxLines: _expanded ? null : _collapsedMaxLines,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (overflows) ...[
              const SizedBox(height: AsmSpacing.xxs),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Weniger anzeigen' : 'Mehr anzeigen',
                  style: AsmTextStyles.bodyM.copyWith(
                    color: AsmColors.brandBright,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
