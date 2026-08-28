import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AsmTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AsmColors.brandBright,
      onPrimary: AsmColors.onBrand,
      primaryContainer: AsmColors.brand,
      onPrimaryContainer: AsmColors.textPrimary,
      secondary: AsmColors.brand,
      onSecondary: AsmColors.textPrimary,
      surface: AsmColors.surface,
      onSurface: AsmColors.textPrimary,
      surfaceContainerHighest: AsmColors.surfaceRaised,
      onSurfaceVariant: AsmColors.textSecondary,
      error: AsmColors.dangerText,
      onError: AsmColors.onBrand,
      outline: AsmColors.border,
      outlineVariant: AsmColors.border,
      scrim: AsmColors.scrim,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AsmColors.bg,
      canvasColor: AsmColors.bg,
      splashFactory: InkSparkle.splashFactory,
      fontFamily: 'Inter',

      textTheme: const TextTheme(
        displayLarge: AsmTextStyles.displayL,
        displayMedium: AsmTextStyles.displayM,
        titleLarge: AsmTextStyles.titleL,
        titleMedium: AsmTextStyles.titleM,
        titleSmall: AsmTextStyles.titleS,
        bodyLarge: AsmTextStyles.bodyL,
        bodyMedium: AsmTextStyles.bodyM,
        bodySmall: AsmTextStyles.bodyS,
        labelMedium: AsmTextStyles.label,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AsmColors.bg,
        foregroundColor: AsmColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AsmTextStyles.titleL,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: AsmColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AsmRadius.lg),
          side: const BorderSide(color: AsmColors.border),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AsmColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AsmSpacing.md,
          vertical: AsmSpacing.sm,
        ),
        hintStyle: AsmTextStyles.bodyM.copyWith(color: AsmColors.textTertiary),
        errorStyle: AsmTextStyles.bodyS.copyWith(color: AsmColors.dangerText),
        border: _inputBorder(AsmColors.border),
        enabledBorder: _inputBorder(AsmColors.border),
        focusedBorder: _inputBorder(AsmColors.brandBright, width: 1.5),
        errorBorder: _inputBorder(AsmColors.dangerText, width: 1.5),
        focusedErrorBorder: _inputBorder(AsmColors.dangerText, width: 1.5),
      ),

      dividerTheme: const DividerThemeData(
        color: AsmColors.border,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AsmColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AsmRadius.xl),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AsmColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AsmTextStyles.titleM,
        contentTextStyle: AsmTextStyles.bodyM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AsmRadius.lg),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AsmColors.surfaceRaised,
        contentTextStyle: AsmTextStyles.bodyM,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AsmRadius.md),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AsmColors.brandBright,
        linearTrackColor: AsmColors.surfaceRaised,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AsmRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
