import 'package:flutter/material.dart';

import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/core/design_system/tokens/app_radius.dart';
import 'package:tictactoe/core/design_system/tokens/app_spacing.dart';

@immutable
final class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    this.spacingXs = AppSpacing.xs,
    this.spacingSm = AppSpacing.sm,
    this.spacingMd = AppSpacing.md,
    this.spacingLg = AppSpacing.lg,
    this.spacingXl = AppSpacing.xl,
    this.spacingXxl = AppSpacing.xxl,
    this.radiusSmall = AppRadius.small,
    this.radiusMedium = AppRadius.medium,
    this.radiusLarge = AppRadius.large,
    this.durationMicro = AppDurations.micro,
    this.durationShort = AppDurations.short,
    this.durationMedium = AppDurations.medium,
    this.durationLong = AppDurations.long,
  });

  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double spacingXxl;

  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;

  final Duration durationMicro;
  final Duration durationShort;
  final Duration durationMedium;
  final Duration durationLong;

  static AppTokens of(BuildContext context) {
    return Theme.of(context).extension<AppTokens>() ?? const AppTokens();
  }

  @override
  AppTokens copyWith({
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? spacingXxl,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    Duration? durationMicro,
    Duration? durationShort,
    Duration? durationMedium,
    Duration? durationLong,
  }) {
    return AppTokens(
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      spacingXxl: spacingXxl ?? this.spacingXxl,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      durationMicro: durationMicro ?? this.durationMicro,
      durationShort: durationShort ?? this.durationShort,
      durationMedium: durationMedium ?? this.durationMedium,
      durationLong: durationLong ?? this.durationLong,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) {
      return this;
    }

    return this;
  }
}
