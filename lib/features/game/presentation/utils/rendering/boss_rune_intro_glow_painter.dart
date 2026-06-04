import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tictactoe/features/game/presentation/utils/bosses/boss_glow_palette.dart';

class BossRuneIntroGlowPainter extends CustomPainter {
  const BossRuneIntroGlowPainter({
    required this.center,
    required this.shineProgress,
    required this.returnProgress,
    required this.opacity,
    this.glowPalette = BossGlowPalette.guided,
  });

  final Offset center;
  final double shineProgress;
  final double returnProgress;
  final double opacity;
  final BossGlowPalette glowPalette;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || shineProgress <= 0) {
      return;
    }

    final hold = (1 - returnProgress).clamp(0.0, 1.0);
    final glowOpacity = (opacity * hold * shineProgress).clamp(0.0, 1.0);
    if (glowOpacity <= 0) {
      return;
    }

    final eased = Curves.easeOutCubic.transform(shineProgress.clamp(0.0, 1.0));
    final breath = math.sin(shineProgress * math.pi).abs();
    final baseRadius = 64 + eased * 118;
    final auraRect = Rect.fromCircle(center: center, radius: baseRadius * 1.28);
    final aura = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          glowPalette.core.withValues(alpha: glowOpacity * 0.09),
          glowPalette.particle.withValues(alpha: glowOpacity * 0.13),
          glowPalette.primary.withValues(alpha: glowOpacity * 0.065),
          glowPalette.secondary.withValues(alpha: glowOpacity * 0.028),
          const Color(0x00000000),
        ],
        stops: const [0, 0.24, 0.48, 0.72, 1],
      ).createShader(auraRect);
    canvas.drawCircle(center, baseRadius * 1.28, aura);

    final mist = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    final crisp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);

    for (var index = 0; index < 12; index++) {
      final angle = index * math.pi / 6 + eased * 0.38;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final tangent = Offset(-direction.dy, direction.dx);
      final start = center + direction * (baseRadius * 0.28);
      final end = center + direction * (baseRadius * (0.86 + breath * 0.08));
      final side = index.isEven ? 1.0 : -1.0;
      final sway = 18 + (index % 3) * 8 + breath * 10;
      final controlA =
          center + direction * (baseRadius * 0.46) + tangent * sway * side;
      final controlB =
          center +
          direction * (baseRadius * 0.68) -
          tangent * sway * 0.5 * side;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          controlA.dx,
          controlA.dy,
          controlB.dx,
          controlB.dy,
          end.dx,
          end.dy,
        );
      final strandOpacity = glowOpacity * (index.isEven ? 0.18 : 0.12);
      final shaderRect = Rect.fromPoints(start, end).inflate(36);

      mist
        ..strokeWidth = 4.6 + (index % 3) * 0.7
        ..shader = LinearGradient(
          colors: [
            glowPalette.particle.withValues(alpha: 0),
            glowPalette.particle.withValues(alpha: strandOpacity * 0.18),
            glowPalette.particle.withValues(alpha: strandOpacity),
            glowPalette.core.withValues(alpha: strandOpacity * 0.42),
            glowPalette.primary.withValues(alpha: strandOpacity * 0.12),
            glowPalette.primary.withValues(alpha: 0),
          ],
          stops: const [0, 0.22, 0.46, 0.58, 0.78, 1],
        ).createShader(shaderRect);
      canvas.drawPath(path, mist);

      crisp
        ..strokeWidth = 0.72 + (index % 2) * 0.18
        ..shader = LinearGradient(
          colors: [
            glowPalette.particle.withValues(alpha: 0),
            glowPalette.core.withValues(alpha: strandOpacity * 0.22),
            glowPalette.particle.withValues(alpha: strandOpacity * 0.3),
            glowPalette.core.withValues(alpha: strandOpacity * 0.14),
            glowPalette.primary.withValues(alpha: 0),
          ],
          stops: const [0, 0.34, 0.48, 0.62, 1],
        ).createShader(shaderRect);
      canvas.drawPath(path, crisp);
    }
  }

  @override
  bool shouldRepaint(BossRuneIntroGlowPainter oldDelegate) {
    return center != oldDelegate.center ||
        shineProgress != oldDelegate.shineProgress ||
        returnProgress != oldDelegate.returnProgress ||
        glowPalette != oldDelegate.glowPalette ||
        opacity != oldDelegate.opacity;
  }
}
