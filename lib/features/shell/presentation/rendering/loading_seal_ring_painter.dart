import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';

final class LoadingSealRingPainter extends CustomPainter {
  const LoadingSealRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final eased = Curves.easeInOutCubic.transform(progress);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppPalette.gold.withValues(alpha: AppAlphas.subtle);
    canvas.drawCircle(center, radius, track);
    canvas.drawCircle(center, radius * 0.9, track);

    final seal = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6
      ..color = AppPalette.goldBright.withValues(alpha: AppAlphas.prominent)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * eased,
      false,
      seal,
    );

    final tick = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4
      ..color = AppPalette.gold.withValues(alpha: AppAlphas.muted);
    const count = 24;
    final rotation = eased * math.pi * 0.5;
    for (var index = 0; index < count; index++) {
      final angle = rotation + index * math.pi * 2 / count;
      final inner = index.isEven ? radius * 0.9 : radius * 0.94;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * inner,
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LoadingSealRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
