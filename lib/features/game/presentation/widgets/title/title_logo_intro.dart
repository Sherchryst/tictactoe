import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tictactoe/app/router/hero_tags.dart';
import 'package:tictactoe/design_system/tokens/app_animations.dart';
import 'package:tictactoe/design_system/widgets/tic_tac_toe_title_logo.dart';
import 'package:tictactoe/features/game/presentation/widgets/title/title_logo_prelude_glow.dart';

class TitleLogoIntro extends StatelessWidget {
  const TitleLogoIntro({required this.controller, super.key});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) =>
          _TitleLogoIntroFrame(progress: controller.value, child: child!),
      child: const Hero(tag: HeroTags.titleLogo, child: TicTacToeTitleLogo()),
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
