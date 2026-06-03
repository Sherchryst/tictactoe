import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tictactoe/core/design_system/theme/app_palette.dart';

enum AmbientMoteFlow { drift, twinkle }

class AmbientMotes extends StatelessWidget {
  const AmbientMotes({
    required this.controller,
    this.count = 42,
    this.maxAlpha = 0.44,
    this.flow = AmbientMoteFlow.drift,
    super.key,
  });

  final Animation<double> controller;
  final int count;
  final double maxAlpha;
  final AmbientMoteFlow flow;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _AmbientMotesPainter(
            progress: controller.value,
            count: count,
            maxAlpha: maxAlpha,
            flow: flow,
          ),
        );
      },
    );
  }
}

class _AmbientMotesPainter extends CustomPainter {
  const _AmbientMotesPainter({
    required this.progress,
    required this.count,
    required this.maxAlpha,
    required this.flow,
  });

  final double progress;
  final int count;
  final double maxAlpha;
  final AmbientMoteFlow flow;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var index = 0; index < count; index++) {
      final seed = index * (flow == AmbientMoteFlow.drift ? 19.17 : 37.17);
      final x = (math.sin(seed) * 0.5 + 0.5) * size.width;
      final radius = 0.8 + (index % 5) * 0.34;
      final double y;
      final double alpha;

      switch (flow) {
        case AmbientMoteFlow.drift:
          final drift = (progress + index * 0.037) % 1;
          y = size.height * (1.08 - drift * 1.22);
          alpha = (math.sin((drift + index) * math.pi) * 0.5 + 0.5) * maxAlpha;
        case AmbientMoteFlow.twinkle:
          final travel = size.height * (0.08 + (index % 7) * 0.018);
          final yBase = (math.cos(seed * 1.7) * 0.5 + 0.5) * size.height;
          y = (yBase - progress * travel) % size.height;
          final twinkle = math.sin(progress * math.pi * 2 + index).abs();
          alpha = 0.06 + twinkle * (maxAlpha - 0.06).clamp(0.0, maxAlpha);
      }

      paint.color = AppPalette.goldBright.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientMotesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.count != count ||
        oldDelegate.maxAlpha != maxAlpha ||
        oldDelegate.flow != flow;
  }
}
