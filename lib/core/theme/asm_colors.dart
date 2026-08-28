import 'package:flutter/material.dart';

/// Alle Farben der App. Keine Farbe darf ausserhalb dieser Klasse
/// als Literal im Code stehen.
abstract final class AsmColors {
  // Core
  static const bg = Color(0xFF171A18);
  static const surface = Color(0xFF222622);
  static const surfaceRaised = Color(0xFF2B302B);
  static const border = Color(0xFF3A403A);

  // Brand
  static const brand = Color(0xFF68745A);
  static const brandBright = Color(0xFF7D8B6A);
  static const brandHi = Color(0xFF93A17E);
  static const brandDim = Color(0xFF566047);
  static const onBrand = Color(0xFF171A18);

  // Text
  static const textPrimary = Color(0xFFE8EAE5);
  static const textSecondary = Color(0xFFA8ADA4);
  static const textTertiary = Color(0xFF7A8078);

  // Status – Flaechen/Icons
  static const success = Color(0xFF5F8A62);
  static const warning = Color(0xFFB49A62);
  static const danger = Color(0xFFA85F59);

  // Status – Text (kontraststark genug fuer Fliesstext)
  static const successText = Color(0xFF7FA882);
  static const warningText = Color(0xFFB49A62);
  static const dangerText = Color(0xFFC97F78);

  // Sonstiges
  static const scrim = Color(0x99000000);
  static const shimmerBase = Color(0xFF222622);
  static const shimmerHi = Color(0xFF2B302B);
}
