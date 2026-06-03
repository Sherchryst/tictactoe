import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_shadows.dart';

final class AppTypography {
  AppTypography._(this._textTheme);

  final TextTheme _textTheme;

  static AppTypography of(BuildContext context) {
    return AppTypography._(Theme.of(context).textTheme);
  }

  TextStyle? menuTitle({Color? color, double? fontSize}) {
    return _textTheme.titleLarge?.copyWith(
      color: color ?? AppPalette.goldBright,
      fontFamily: AppPalette.titleFont,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    );
  }

  TextStyle? menuItem({required bool selected, double? fontSize}) {
    return _textTheme.titleLarge?.copyWith(
      color: selected
          ? AppPalette.goldBright
          : AppPalette.ivoryText.withValues(alpha: AppAlphas.prominent),
      fontFamily: AppPalette.titleFont,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      shadows: selected ? AppShadows.goldDimGlow() : null,
    );
  }

  TextStyle? statusHeadline({Color? color}) {
    return _textTheme.titleLarge?.copyWith(
      color: color ?? AppPalette.goldBright,
      fontFamily: AppPalette.serifFont,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      shadows: AppShadows.ivoryGlow(alpha: 0.32),
    );
  }

  TextStyle? sectionTitle({Color? color}) {
    return _textTheme.titleMedium?.copyWith(
      color: color ?? AppPalette.ivoryText.withValues(alpha: AppAlphas.opaque),
      fontFamily: AppPalette.serifFont,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );
  }

  TextStyle? rowLabel({required bool selected}) {
    return _textTheme.titleMedium?.copyWith(
      color: selected
          ? AppPalette.ivoryText
          : AppPalette.ivoryText.withValues(alpha: 0.72),
      fontFamily: AppPalette.serifFont,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      letterSpacing: 0,
    );
  }

  TextStyle? metricValue() {
    return _textTheme.headlineSmall?.copyWith(
      color: AppPalette.goldBright,
      fontFamily: AppPalette.serifFont,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    );
  }

  TextStyle? helpText() {
    return _textTheme.bodyMedium?.copyWith(
      color: AppPalette.ivoryText.withValues(alpha: 0.76),
      fontFamily: AppPalette.serifFont,
      letterSpacing: 0,
    );
  }

  TextStyle? toggleValue({required bool enabled}) {
    return _textTheme.labelLarge?.copyWith(
      color: enabled
          ? AppPalette.goldBright
          : AppPalette.ivoryText.withValues(alpha: 0.5),
      fontFamily: AppPalette.serifFont,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );
  }

  TextStyle? bannerHeadline({
    required Color color,
    required Color shadowColor,
    required double fontSize,
  }) {
    return _textTheme.displayMedium?.copyWith(
      color: color,
      fontFamily: AppPalette.serifFont,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      shadows: [
        Shadow(color: shadowColor.withValues(alpha: 0.9), blurRadius: 8),
      ],
    );
  }

  TextStyle? chromeMark({required bool active}) {
    return _textTheme.bodySmall?.copyWith(
      color: active
          ? AppPalette.goldBright
          : AppPalette.ivoryText.withValues(alpha: AppAlphas.muted),
      fontFamily: AppPalette.serifFont,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.6,
    );
  }

  TextStyle? scoreTileValue() {
    return _textTheme.headlineSmall?.copyWith(
      fontFamily: AppPalette.serifFont,
      fontWeight: FontWeight.w500,
      color: AppPalette.goldBright,
    );
  }

  TextStyle? scoreTileLabel() {
    return _textTheme.bodySmall?.copyWith(
      color: AppPalette.mutedText,
      fontFamily: AppPalette.serifFont,
    );
  }

  TextStyle? prompt({required double fontSize}) {
    return _textTheme.bodyMedium?.copyWith(
      color: AppPalette.goldBright,
      fontFamily: AppPalette.titleFont,
      fontSize: fontSize,
      letterSpacing: 0,
      shadows: AppShadows.goldDimGlow(),
    );
  }

  TextStyle? dialogAction({required bool pressed}) {
    return _textTheme.titleMedium?.copyWith(
      color: pressed
          ? AppPalette.goldBright
          : AppPalette.ivoryText.withValues(alpha: 0.7),
      fontFamily: AppPalette.titleFont,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      shadows: pressed
          ? [
              Shadow(
                color: AppPalette.gold.withValues(alpha: 0.42),
                blurRadius: 14,
              ),
            ]
          : null,
    );
  }
}
