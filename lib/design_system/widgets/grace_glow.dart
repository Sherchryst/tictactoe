import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_alphas.dart';

class GraceGlow extends StatelessWidget {
  const GraceGlow({
    required this.animation,
    this.alignment = const Alignment(0, 1.05),
    this.radius = 1,
    this.intensity = 1,
    this.color = AppPalette.gold,
    super.key,
  });

  final Animation<double> animation;
  final Alignment alignment;
  final double radius;
  final double intensity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final pulse =
                0.78 +
                (math.sin(animation.value * math.pi * 2) * 0.5 + 0.5) * 0.22;
            final glow = (intensity * pulse).clamp(0.0, 1.0);

            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: alignment,
                  radius: radius,
                  colors: [
                    color.withValues(alpha: AppAlphas.muted * glow),
                    color.withValues(alpha: AppAlphas.faint * glow),
                    const Color(0x00000000),
                  ],
                  stops: const [0, 0.42, 1],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
