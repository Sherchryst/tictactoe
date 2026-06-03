import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tictactoe/design_system/theme/app_palette.dart';

class FogVeil extends StatelessWidget {
  const FogVeil({
    required this.animation,
    this.intensity = 1,
    this.verticalBias = 0.5,
    this.spread = 1,
    this.color = AppPalette.gold,
    super.key,
  });

  final Animation<double> animation;
  final double intensity;
  final double verticalBias;
  final double spread;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _FogVeilPainter(
                progress: animation.value,
                intensity: intensity,
                verticalBias: verticalBias,
                spread: spread,
                color: color,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FogVeilPainter extends CustomPainter {
  _FogVeilPainter({
    required this.progress,
    required this.intensity,
    required this.verticalBias,
    required this.spread,
    required this.color,
  });

  static const _bands = 6;

  final double progress;
  final double intensity;
  final double verticalBias;
  final double spread;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) {
      return;
    }

    for (var index = 0; index < _bands; index++) {
      final phase = progress * math.pi * 2 + index * 1.7;
      final direction = index.isEven ? 1.0 : -1.0;
      final fraction = index / (_bands - 1);
      final cx = size.width * (0.5 + direction * math.sin(phase) * 0.22);
      final cy = size.height * (verticalBias + (fraction - 0.5) * spread);
      final bandWidth = size.width * (1.05 + (index % 3) * 0.18);
      final bandHeight = size.height * (0.14 + (index % 2) * 0.05);
      final wave = math.sin(phase * 0.5) * 0.5 + 0.5;
      final alpha = (intensity * (0.04 + wave * 0.05)).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 38);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: bandWidth,
          height: bandHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FogVeilPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.intensity != intensity ||
        oldDelegate.verticalBias != verticalBias ||
        oldDelegate.spread != spread ||
        oldDelegate.color != color;
  }
}
