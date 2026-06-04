import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/tokens/app_animations.dart';
import 'package:tictactoe/core/design_system/widgets/tic_tac_toe_title_logo.dart';
import 'package:tictactoe/core/router/hero_tags.dart';
import 'package:tictactoe/features/launch/presentation/widgets/title/title_logo_prelude_glow.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class TitleLogoIntro extends StatelessWidget {
  const TitleLogoIntro({
    required this.controller,
    this.enableHero = true,
    super.key,
  });

  final AnimationController controller;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) =>
          _TitleLogoIntroFrame(progress: controller.value, child: child!),
      child: enableHero
          ? Hero(
              tag: HeroTags.titleLogo,
              child: TicTacToeTitleLogo(title: l10n.appTitle),
            )
          : TicTacToeTitleLogo(title: l10n.appTitle),
    );
  }
}

class _TitleLogoIntroFrame extends StatelessWidget {
  const _TitleLogoIntroFrame({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final preGlow = AppAnimations.interval(
      progress,
      begin: 0,
      end: 0.5,
      curve: Curves.easeInOutCubic,
    );
    final logoMotion = AppAnimations.interval(
      progress,
      begin: 0.06,
      end: 1,
      curve: Curves.easeInOutCubic,
    );
    final logoOpacity = AppAnimations.interval(
      progress,
      begin: 0.08,
      end: 0.92,
      curve: Curves.easeInOutCubic,
    );
    final arcLift = math.sin(logoMotion * math.pi) * 10;
    final verticalOffset = 92 * (1 - logoMotion) - arcLift;
    final glowOpacity =
        (0.36 * preGlow * (1 - logoOpacity * 0.58) + 0.06 * logoOpacity)
            .clamp(0.0, 0.38)
            .toDouble();

    return Transform.translate(
      offset: Offset(0, verticalOffset),
      child: Transform.scale(
        scale:
            0.94 + logoMotion * 0.06 + math.sin(logoMotion * math.pi) * 0.012,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: glowOpacity,
                child: const TitleLogoPreludeGlow(),
              ),
            ),
            Opacity(opacity: logoOpacity.clamp(0.0, 1.0), child: child),
          ],
        ),
      ),
    );
  }
}
