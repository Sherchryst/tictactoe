import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';

class RuneDiamond extends StatelessWidget {
  const RuneDiamond({
    this.size = 5,
    this.color = AppPalette.goldBright,
    this.glow = true,
    super.key,
  });

  final double size;
  final Color color;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: AppAlphas.prominent),
                    blurRadius: size * 1.6,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
