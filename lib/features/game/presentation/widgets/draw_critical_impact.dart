import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tictactoe/design_system/theme/app_palette.dart';

class DrawCriticalImpact extends StatelessWidget {
  const DrawCriticalImpact({
    required this.duration,
    required this.trigger,
    super.key,
  });

  final Duration duration;
  final Object trigger;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(trigger),
          tween: Tween(begin: 0, end: 1),
          duration: duration,
          builder: (context, progress, child) {
            return CustomPaint(painter: _DrawCriticalImpactPainter(progress));
          },
        ),
      ),
    );
  }
}

class _DrawCriticalImpactPainter extends CustomPainter {
  const _DrawCriticalImpactPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.48);
    final shortest = size.shortestSide;
    final burst = _interval(progress, 0, 0.38, Curves.easeOutCubic);
    final settle = _interval(progress, 0.32, 1, Curves.easeInCubic);
    final flashOpacity =
        (1 - _interval(progress, 0.04, 0.5, Curves.easeOutCubic))
            .clamp(0.0, 1.0)
            .toDouble();
    final emberOpacity = (1 - settle).clamp(0.0, 1.0).toDouble();

    canvas.saveLayer(Offset.zero & size, Paint()..blendMode = BlendMode.plus);
    _paintFlash(canvas, center, shortest, burst, flashOpacity);
    _paintRings(canvas, center, shortest, burst, emberOpacity);
    _paintRays(canvas, center, shortest, burst, emberOpacity);
    _paintSparks(canvas, center, shortest, burst, emberOpacity);
    canvas.restore();
  }

  void _paintFlash(
    Canvas canvas,
    Offset center,
    double shortest,
    double burst,
    double opacity,
  ) {
    final corePaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppPalette.goldBright.withValues(alpha: 0.52 * opacity),
              AppPalette.gold.withValues(alpha: 0.22 * opacity),
              Colors.transparent,
            ],
            stops: const [0, 0.34, 1],
          ).createShader(
            Rect.fromCircle(
              center: center,
              radius: shortest * (0.12 + burst * 0.48),
            ),
          )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    final hazePaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppPalette.gold.withValues(alpha: 0.2 * opacity),
              AppPalette.goldDim.withValues(alpha: 0.08 * opacity),
              Colors.transparent,
            ],
            stops: const [0, 0.4, 1],
          ).createShader(
            Rect.fromCenter(
              center: center,
              width: shortest * (0.72 + burst * 1.25),
              height: shortest * (0.38 + burst * 0.76),
            ),
          )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: shortest * (0.72 + burst * 1.25),
        height: shortest * (0.38 + burst * 0.76),
      ),
      hazePaint,
    );
    canvas.drawCircle(center, shortest * (0.12 + burst * 0.48), corePaint);
  }

  void _paintRings(
    Canvas canvas,
    Offset center,
    double shortest,
    double burst,
    double opacity,
  ) {
    for (var index = 0; index < 3; index++) {
      final lag = index * 0.12;
      final ring = ((burst - lag) / (1 - lag)).clamp(0.0, 1.0).toDouble();
      if (ring <= 0) {
        continue;
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 + (1 - ring) * 2.8
        ..color = AppPalette.goldBright.withValues(
          alpha: opacity * (1 - ring) * (0.42 - index * 0.08),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(center, shortest * (0.08 + ring * 0.62), paint);
    }
  }

  void _paintRays(
    Canvas canvas,
    Offset center,
    double shortest,
    double burst,
    double opacity,
  ) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4
      ..color = AppPalette.goldBright.withValues(alpha: opacity * 0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (var index = 0; index < 16; index++) {
      final angle = (math.pi * 2 / 16) * index + 0.16;
      final start = shortest * (0.05 + burst * 0.08);
      final end = shortest * (0.17 + burst * 0.72);
      final from = center + Offset(math.cos(angle), math.sin(angle)) * start;
      final to = center + Offset(math.cos(angle), math.sin(angle)) * end;
      canvas.drawLine(from, to, paint);
    }
  }

  void _paintSparks(
    Canvas canvas,
    Offset center,
    double shortest,
    double burst,
    double opacity,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var index = 0; index < 28; index++) {
      final seed = index * 1.618;
      final angle = seed * math.pi;
      final distance = shortest * (0.08 + burst * (0.18 + (index % 9) * 0.045));
      final drift = Offset(math.cos(angle), math.sin(angle)) * distance;
      final verticalDrift = Offset(0, math.sin(seed * 3) * shortest * 0.02);
      final radius = 1.2 + (index % 4) * 0.55;
      final alpha = opacity * (0.18 + (index % 5) * 0.055);

      paint.color = AppPalette.goldBright.withValues(alpha: alpha);
      canvas.drawCircle(center + drift + verticalDrift, radius, paint);
    }
  }

  double _interval(double value, double begin, double end, Curve curve) {
    final normalized = ((value - begin) / (end - begin)).clamp(0.0, 1.0);
    return curve.transform(normalized);
  }

  @override
  bool shouldRepaint(covariant _DrawCriticalImpactPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
