import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';

final class TitleLogoPreludeGlowPainter extends CustomPainter {
  const TitleLogoPreludeGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..shader =
          RadialGradient(
            radius: 0.7,
            colors: [
              AppPalette.goldBright.withValues(alpha: 0.62),
              AppPalette.gold.withValues(alpha: 0.28),
              const Color(0x00000000),
            ],
            stops: const [0, 0.32, 1],
          ).createShader(
            Rect.fromCenter(
              center: center,
              width: size.width * 1.08,
              height: size.height * 1.18,
            ),
          )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.92,
        height: size.height * 0.72,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant TitleLogoPreludeGlowPainter oldDelegate) {
    return false;
  }
}
