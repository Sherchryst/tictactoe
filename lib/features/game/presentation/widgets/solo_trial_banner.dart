import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/design_system/tokens/app_curves.dart';
import 'package:tictactoe/design_system/tokens/app_durations.dart';
import 'package:tictactoe/design_system/tokens/app_typography.dart';
import 'package:tictactoe/design_system/widgets/app_haptics.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/game_audio_effects.dart';

class SoloTrialBanner extends HookWidget {
  const SoloTrialBanner({required this.mode, required this.result, super.key});

  final GameMode mode;
  final GameResult result;

  @override
  Widget build(BuildContext context) {
    final banner = _bannerFor(mode, result);
    final activeLabel = banner?.label;

    useEffect(() {
      if (activeLabel != null) {
        AppHaptics.outcome();
      }
      return null;
    }, [activeLabel]);

    if (banner == null) {
      return const SizedBox.shrink();
    }

    final screen = MediaQuery.sizeOf(context);
    final bandHeight = (screen.height * 0.105).clamp(78.0, 118.0).toDouble();
    final fontSize = (screen.shortestSide * 0.125).clamp(42.0, 72.0).toDouble();

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            key: ValueKey(banner.label),
            tween: Tween(begin: 0, end: 1),
            duration: banner.totalAnimationDuration,
            builder: (context, value, child) {
              final elapsed = Duration(
                milliseconds:
                    (banner.totalAnimationDuration.inMilliseconds * value)
                        .round(),
              );
              final bandProgress = AppCurves.entrance.transform(
                (elapsed.inMilliseconds /
                        banner.bandGrowDuration.inMilliseconds)
                    .clamp(0.0, 1.0),
              );
              final textProgress = AppCurves.entrance.transform(
                ((elapsed - banner.textRevealDelay).inMilliseconds /
                        banner.textFadeDuration.inMilliseconds)
                    .clamp(0.0, 1.0),
              );

              return _SoloTrialBannerFrame(
                banner: banner,
                bandHeight: bandHeight,
                fontSize: fontSize,
                lineProgress: bandProgress,
                revealProgress: textProgress,
              );
            },
          ),
        ),
      ),
    );
  }

  _SoloTrialBannerStyle? _bannerFor(GameMode mode, GameResult result) {
    if (mode != GameMode.humanVsCpu) {
      return null;
    }

    return switch (result) {
      GameWin(:final winner) =>
        winner == Player.human
            ? const _SoloTrialBannerStyle(
                label: 'GOD SLAIN',
                textColor: AppPalette.goldBright,
                borderColor: AppPalette.goldDim,
                shadowColor: AppPalette.victoryShadow,
                bandGrowDuration: GameAudioEffects.parryDuration,
                textRevealDelay: GameAudioEffects.parryDuration,
                showIntroLine: false,
              )
            : const _SoloTrialBannerStyle(
                label: 'YOU DIED',
                textColor: AppPalette.lossRed,
                borderColor: AppPalette.lossRedDeep,
                shadowColor: AppPalette.lossShadow,
                bandGrowDuration: AppDurations.bannerDeathBand,
                textRevealDelay: Duration.zero,
                showIntroLine: true,
              ),
      GameDraw() || GameOngoing() => null,
    };
  }
}

class _SoloTrialBannerStyle {
  const _SoloTrialBannerStyle({
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.shadowColor,
    required this.bandGrowDuration,
    required this.textRevealDelay,
    required this.showIntroLine,
  });

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

class _SoloTrialBannerFrame extends StatelessWidget {
  const _SoloTrialBannerFrame({
    required this.banner,
    required this.bandHeight,
    required this.fontSize,
    required this.lineProgress,
    required this.revealProgress,
  });

  final _SoloTrialBannerStyle banner;
  final double bandHeight;
  final double fontSize;
  final double lineProgress;
  final double revealProgress;

  @override
  Widget build(BuildContext context) {
    final introLineOpacity = (lineProgress * (1 - revealProgress))
        .clamp(0.0, 1.0)
        .toDouble();

    return SizedBox(
      width: double.infinity,
      height: bandHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (banner.showIntroLine)
            _IntroLine(
              banner: banner,
              lineProgress: lineProgress,
              opacity: introLineOpacity,
            ),
          _BannerBackground(banner: banner, revealProgress: revealProgress),
          _BannerLabel(
            banner: banner,
            fontSize: fontSize,
            revealProgress: revealProgress,
          ),
        ],
      ),
    );
  }
}

class _IntroLine extends StatelessWidget {
  const _IntroLine({
    required this.banner,
    required this.lineProgress,
    required this.opacity,
  });

  final _SoloTrialBannerStyle banner;
  final double lineProgress;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      height: 3,
      child: Transform.scale(
        scaleX: lineProgress,
        child: Opacity(
          opacity: opacity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0x00000000),
                  banner.borderColor.withValues(alpha: 0.52),
                  banner.textColor.withValues(alpha: 0.72),
                  banner.borderColor.withValues(alpha: 0.52),
                  const Color(0x00000000),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: banner.borderColor.withValues(alpha: AppAlphas.muted),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerBackground extends StatelessWidget {
  const _BannerBackground({required this.banner, required this.revealProgress});

  final _SoloTrialBannerStyle banner;
  final double revealProgress;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: revealProgress,
        child: Transform.scale(
          scaleX: 0.98 + revealProgress * 0.02,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppPalette.backgroundDeep.withValues(alpha: 0.74),
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: banner.borderColor.withValues(alpha: AppAlphas.medium),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.shadow.withValues(alpha: 0.66),
                  blurRadius: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerLabel extends StatelessWidget {
  const _BannerLabel({
    required this.banner,
    required this.fontSize,
    required this.revealProgress,
  });

  final _SoloTrialBannerStyle banner;
  final double fontSize;
  final double revealProgress;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: revealProgress,
      child: Transform.scale(
        scale: 0.985 + revealProgress * 0.015,
        child: Text(
          banner.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.of(context).bannerHeadline(
            color: banner.textColor,
            shadowColor: banner.shadowColor,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
