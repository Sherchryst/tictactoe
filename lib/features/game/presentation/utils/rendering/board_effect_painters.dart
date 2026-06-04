import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';

class ImpactFlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.38;
    final fill = Paint()
      ..color = AppPalette.goldBright.withValues(alpha: 0.34)
      ..style = PaintingStyle.fill;
    final ring = Paint()
      ..color = AppPalette.gold.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final ray = Paint()
      ..color = AppPalette.goldBright.withValues(alpha: 0.66)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius * 0.58, ring);
    canvas.drawCircle(
      center,
      radius * 0.86,
      ring..color = ring.color.withValues(alpha: 0.42),
    );

    for (var index = 0; index < 8; index++) {
      final angle = index * math.pi / 4;
      final from = Offset(
        center.dx + math.cos(angle) * radius * 0.22,
        center.dy + math.sin(angle) * radius * 0.22,
      );
      final to = Offset(
        center.dx + math.cos(angle) * radius * 1.22,
        center.dy + math.sin(angle) * radius * 1.22,
      );
      canvas.drawLine(from, to, ray);
    }
  }

  @override
  bool shouldRepaint(covariant ImpactFlashPainter oldDelegate) => false;
}

class SlashPainter extends CustomPainter {
  const SlashPainter({required this.isGold});

  final bool isGold;

  @override
  void paint(Canvas canvas, Size size) {
    final color = isGold ? AppPalette.goldBright : AppPalette.ashGray;
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.76)
      ..cubicTo(
        size.width * 0.32,
        size.height * 0.56,
        size.width * 0.6,
        size.height * 0.28,
        size.width * 0.9,
        size.height * 0.12,
      );
    final glow = Paint()
      ..color = color.withValues(alpha: isGold ? 0.42 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16;
    final edge = Paint()
      ..color = color.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    canvas.drawPath(path, glow);
    canvas.drawPath(path, edge);
  }

  @override
  bool shouldRepaint(covariant SlashPainter oldDelegate) {
    return oldDelegate.isGold != isGold;
  }
}

class ParticleRingPainter extends CustomPainter {
  const ParticleRingPainter({required this.progress, required this.isGold});

  final double progress;
  final bool isGold;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = (isGold ? AppPalette.goldBright : AppPalette.ashGray)
          .withValues(alpha: (1 - progress).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    for (var index = 0; index < 10; index++) {
      final angle = index * math.pi / 5;
      final distance = size.shortestSide * (0.08 + progress * 0.32);
      final point = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance * 0.78,
      );
      canvas.drawCircle(point, index.isEven ? 2.4 : 1.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isGold != isGold;
  }
}

class DrawFogPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppPalette.ashGray.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.12;

    for (var index = 0; index < 3; index++) {
      final offset = index * size.height * 0.16;
      final path = Path()
        ..moveTo(size.width * 0.02, size.height * 0.28 + offset)
        ..cubicTo(
          size.width * 0.28,
          size.height * 0.08 + offset,
          size.width * 0.54,
          size.height * 0.52 + offset,
          size.width * 0.98,
          size.height * 0.24 + offset,
        );
      canvas.drawPath(
        path,
        paint..color = paint.color.withValues(alpha: 0.16 - index * 0.03),
      );
    }
  }

  @override
  bool shouldRepaint(covariant DrawFogPainter oldDelegate) => false;
}
