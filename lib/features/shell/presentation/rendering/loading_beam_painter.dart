import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';

final class LoadingBeamPainter extends CustomPainter {
  const LoadingBeamPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    if (clampedProgress == 0) {
      return;
    }

    final center = size.center(Offset.zero);
    final lineWidth = size.width * clampedProgress;
    final lineRect = Rect.fromCenter(
      center: center,
      width: lineWidth,
      height: size.height,
    );
    final haloPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, AppPalette.goldBright, Colors.transparent],
      ).createShader(lineRect)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(6, size.height * 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    final corePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          AppPalette.gold,
          AppPalette.ivoryText,
          AppPalette.gold,
          Colors.transparent,
        ],
      ).createShader(lineRect)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.8, size.height * 0.08);

    canvas.drawLine(
      Offset(center.dx - lineWidth * 0.5, center.dy),
      Offset(center.dx + lineWidth * 0.5, center.dy),
      haloPaint,
    );
    canvas.drawLine(
      Offset(center.dx - lineWidth * 0.48, center.dy),
      Offset(center.dx + lineWidth * 0.48, center.dy),
      corePaint,
    );
  }

  @override
  bool shouldRepaint(LoadingBeamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
