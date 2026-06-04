import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/widgets/sigil_backdrop.dart';

class TitleBackground extends StatelessWidget {
  const TitleBackground({
    required this.controller,
    required this.sigilTop,
    required this.sigilSize,
    super.key,
  });

  final AnimationController controller;
  final double sigilTop;
  final double sigilSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => _BackgroundFlare(value: controller.value),
          ),
        ),
        Positioned(
          top: sigilTop,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) =>
                _Sigil(value: controller.value, child: child!),
            child: IgnorePointer(child: SigilBackdrop(height: sigilSize)),
          ),
        ),
      ],
    );
  }
}

class _BackgroundFlare extends StatelessWidget {
  const _BackgroundFlare({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final background = Curves.easeOutCubic.transform(value);
    final flare = math.sin(background * math.pi).clamp(0.0, 1.0).toDouble();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.12),
          radius: 0.92,
          colors: [
            AppPalette.gold.withValues(alpha: 0.08 * background + 0.24 * flare),
            AppPalette.goldDim.withValues(
              alpha: 0.04 * background + 0.12 * flare,
            ),
            AppPalette.backgroundDeep,
          ],
          stops: const [0, 0.34, 1],
        ),
      ),
    );
  }
}

class _Sigil extends StatelessWidget {
  const _Sigil({required this.value, required this.child});

  final double value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final background = Curves.easeOutCubic.transform(value);
    final flare = math.sin(background * math.pi).clamp(0.0, 1.0).toDouble();
    final opacity = (0.58 * background + 0.3 * flare)
        .clamp(0.0, 0.86)
        .toDouble();

    return Opacity(
      opacity: opacity,
      child: Transform.scale(scale: 1.05 - background * 0.05, child: child),
    );
  }
}
