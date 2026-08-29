import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';

/// Eingabefeld der App. Siehe 01-DESIGN-SYSTEM.md Abschnitt 5.2.
class AsmTextField extends StatefulWidget {
  const AsmTextField({
    required this.controller,
    required this.label,
    this.errorText,
    this.maxLength,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final int? maxLength;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<AsmTextField> createState() => _AsmTextFieldState();
}

class _AsmTextFieldState extends State<AsmTextField> {
  final _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final (Color borderColor, double borderWidth) = switch ((
      hasError,
      _hasFocus,
    )) {
      (true, _) => (AsmColors.dangerText, 1.5),
      (false, true) => (AsmColors.brandBright, 1.5),
      (false, false) => (AsmColors.border, 1.0),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: AsmTextStyles.label),
        const SizedBox(height: AsmSpacing.xxs),
        Container(
          decoration: BoxDecoration(
            color: AsmColors.surface,
            borderRadius: BorderRadius.circular(AsmRadius.md),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AsmSpacing.sm),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLength: widget.maxLength,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            style: AsmTextStyles.bodyM.copyWith(color: AsmColors.textPrimary),
            cursorColor: AsmColors.brandBright,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: AsmSpacing.sm),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AsmSpacing.xxs),
          Text(
            widget.errorText!,
            style: AsmTextStyles.bodyS.copyWith(color: AsmColors.dangerText),
          ),
        ] else if (widget.maxLength != null) ...[
          const SizedBox(height: AsmSpacing.xxs),
          Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (context, value, _) => Text(
                '${value.text.length}/${widget.maxLength}',
                style: AsmTextStyles.bodyS.copyWith(
                  color: AsmColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
