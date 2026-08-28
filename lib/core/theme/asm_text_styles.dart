import 'package:asm/core/theme/asm_colors.dart';
import 'package:flutter/material.dart';

abstract final class AsmTextStyles {
  static const _inter = 'Inter';
  static const _condensed = 'BarlowCondensed';

  static const displayL = TextStyle(
    fontFamily: _condensed,
    fontSize: 34,
    height: 38 / 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AsmColors.textPrimary,
  );
  static const displayM = TextStyle(
    fontFamily: _condensed,
    fontSize: 26,
    height: 30 / 26,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AsmColors.textPrimary,
  );
  static const titleL = TextStyle(
    fontFamily: _inter,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    color: AsmColors.textPrimary,
  );
  static const titleM = TextStyle(
    fontFamily: _inter,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w600,
    color: AsmColors.textPrimary,
  );
  static const titleS = TextStyle(
    fontFamily: _inter,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
    color: AsmColors.textPrimary,
  );
  static const bodyL = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AsmColors.textPrimary,
  );
  static const bodyM = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AsmColors.textPrimary,
  );
  static const bodyS = TextStyle(
    fontFamily: _inter,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: AsmColors.textSecondary,
  );
  static const label = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AsmColors.textSecondary,
  );
  static const price = TextStyle(
    fontFamily: _inter,
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w700,
    color: AsmColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const priceS = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w700,
    color: AsmColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
