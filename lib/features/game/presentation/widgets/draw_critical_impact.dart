import 'package:flutter/material.dart';

import 'package:tictactoe/features/game/presentation/utils/rendering/draw_critical_impact_painter.dart';

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
            return CustomPaint(painter: DrawCriticalImpactPainter(progress));
          },
        ),
      ),
    );
  }
}
