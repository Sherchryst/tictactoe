import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/features/game/presentation/utils/audio/game_audio_effects.dart';

class SoloTrialBannerStyle {
  const SoloTrialBannerStyle({
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.shadowColor,
    required this.bandGrowDuration,
    required this.textRevealDelay,
    required this.showIntroLine,
  });

  factory SoloTrialBannerStyle.humanWin({
    required String label,
    required bool guided,
  }) {
    final duration = guided
        ? GameAudioEffects.guidedVictoryDelay
        : GameAudioEffects.noMercyVictoryBannerDelay;

    return SoloTrialBannerStyle(
      label: label,
      textColor: AppPalette.goldBright,
      borderColor: AppPalette.goldDim,
      shadowColor: AppPalette.victoryShadow,
      bandGrowDuration: duration,
      textRevealDelay: duration,
      showIntroLine: false,
    );
  }

  factory SoloTrialBannerStyle.cpuWin({required String label}) {
    return SoloTrialBannerStyle(
      label: label,
      textColor: AppPalette.lossRed,
      borderColor: AppPalette.lossRedDeep,
      shadowColor: AppPalette.lossShadow,
      bandGrowDuration: AppDurations.bannerDeathBand,
      textRevealDelay: Duration.zero,
      showIntroLine: true,
    );
  }

  final String label;
  final Color textColor;
  final Color borderColor;
  final Color shadowColor;
  final Duration bandGrowDuration;
  final Duration textRevealDelay;
  final bool showIntroLine;

  Duration get textFadeDuration => AppDurations.bannerTextFade;

  Duration get totalAnimationDuration {
    final textEnd = textRevealDelay + textFadeDuration;
    return bandGrowDuration > textEnd ? bandGrowDuration : textEnd;
  }
}
