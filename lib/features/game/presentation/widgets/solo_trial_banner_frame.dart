import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_typography.dart';
import 'package:tictactoe/features/game/presentation/utils/styles/solo_trial_banner_style.dart';

class SoloTrialBannerFrame extends StatelessWidget {
  const SoloTrialBannerFrame({
    required this.banner,
    required this.bandHeight,
    required this.lineProgress,
    required this.revealProgress,
    super.key,
  });

  final SoloTrialBannerStyle banner;
  final double bandHeight;
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
          _BannerLabel(banner: banner, revealProgress: revealProgress),
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

  final SoloTrialBannerStyle banner;
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

  final SoloTrialBannerStyle banner;
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
  const _BannerLabel({required this.banner, required this.revealProgress});

  final SoloTrialBannerStyle banner;
  final double revealProgress;
  static const _maxFontSize = 64.0;
  static const _minFontSize = 28.0;
  static const _horizontalPadding = 28.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final style = _labelStyle(context, _maxFontSize);
        final fontSize = _fittedFontSize(
          context: context,
          constraints: constraints,
          style: style,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: Opacity(
            opacity: revealProgress,
            child: Transform.scale(
              scale: 0.985 + revealProgress * 0.015,
              child: Text(
                banner.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: _labelStyle(context, fontSize),
              ),
            ),
          ),
        );
      },
    );
  }

  TextStyle _labelStyle(BuildContext context, double fontSize) {
    return AppTypography.of(context).bannerHeadline(
          color: banner.textColor,
          shadowColor: banner.shadowColor,
          fontSize: fontSize,
        ) ??
        TextStyle(
          color: banner.textColor,
          fontSize: fontSize,
          letterSpacing: 0,
        );
  }

  double _fittedFontSize({
    required BuildContext context,
    required BoxConstraints constraints,
    required TextStyle style,
  }) {
    final maxWidth = constraints.maxWidth - _horizontalPadding * 2;
    if (!maxWidth.isFinite || maxWidth <= 0) {
      return _minFontSize;
    }

    var low = _minFontSize;
    var high = _maxFontSize;
    for (var i = 0; i < 8; i++) {
      final mid = (low + high) / 2;
      if (_textWidth(context, style.copyWith(fontSize: mid)) <= maxWidth) {
        low = mid;
      } else {
        high = mid;
      }
    }

    return low;
  }

  double _textWidth(BuildContext context, TextStyle style) {
    final painter = TextPainter(
      maxLines: 1,
      text: TextSpan(text: banner.label, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();

    return painter.width;
  }
}
