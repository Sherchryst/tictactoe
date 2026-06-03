import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_tokens.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppPalette.gold,
      primaryContainer: AppPalette.surfaceRaised,
      onPrimaryContainer: AppPalette.goldBright,
      secondary: AppPalette.emberRed,
      onSecondary: AppPalette.ivoryText,
      secondaryContainer: AppPalette.surfaceRaised,
      onSecondaryContainer: AppPalette.ivoryText,
      tertiary: AppPalette.ceruleanBlue,
      tertiaryContainer: AppPalette.goldDim,
      surface: AppPalette.background,
      surfaceContainerHighest: AppPalette.surfaceRaised,
      onSurface: AppPalette.ivoryText,
      onSurfaceVariant: AppPalette.mutedText,
      outline: AppPalette.goldDim,
      outlineVariant: AppPalette.gridLine,
      error: AppPalette.emberRed,
    );

    final baseTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: AppPalette.serifFont,
    );
    final textTheme = baseTheme.textTheme.copyWith(
      displayLarge: baseTheme.textTheme.displayLarge?.copyWith(
        fontFamily: AppPalette.titleFont,
      ),
      displayMedium: baseTheme.textTheme.displayMedium?.copyWith(
        fontFamily: AppPalette.titleFont,
      ),
      displaySmall: baseTheme.textTheme.displaySmall?.copyWith(
        fontFamily: AppPalette.titleFont,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
        fontFamily: AppPalette.titleFont,
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: AppPalette.serifFont,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppPalette.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppPalette.ivoryText,
      ),
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      dialogTheme: DialogThemeData(
        backgroundColor: AppPalette.backgroundDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppPalette.goldBright,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: AppPalette.serifFont,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.goldBright,
          side: const BorderSide(color: AppPalette.goldDim, width: 0.8),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: AppPalette.serifFont,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.ivoryText,
          textStyle: const TextStyle(
            fontFamily: AppPalette.serifFont,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      extensions: const [AppTokens()],
    );
  }
}
