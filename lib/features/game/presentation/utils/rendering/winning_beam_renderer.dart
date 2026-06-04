import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/presentation/utils/rendering/winning_beam_metrics.dart';
import 'package:tictactoe/features/game/presentation/utils/rendering/winning_beam_palette.dart';

class WinningBeamRenderer {
  const WinningBeamRenderer();

  void paint({
    required Canvas canvas,
    required Size size,
    required List<int> winningCells,
    required Mark winner,
    required double progress,
  }) {
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    if (clampedProgress == 0 || winningCells.length < 3) {
      return;
    }

    final metrics = WinningBeamMetrics.from(size, winningCells);
    if (metrics == null) {
      return;
    }

    final palette = WinningBeamPalette.forWinner(winner);
    final reveal = AppCurves.entrance.transform(clampedProgress);
    final opacity = Curves.easeOutCubic
        .transform((clampedProgress * 1.28).clamp(0.0, 1.0).toDouble())
        .clamp(0.0, 1.0)
        .toDouble();
    final flare = math.sin(clampedProgress * math.pi).clamp(0.0, 1.0);
    final halfSpan = metrics.span * 0.5 * reveal;
    final start = metrics.center - halfSpan;
    final end = metrics.center + halfSpan;

    _paintAura(
      canvas,
      start: start,
      end: end,
      metrics: metrics,
      palette: palette,
      opacity: opacity,
      flare: flare.toDouble(),
    );
    _paintCore(
      canvas,
      start: start,
      end: end,
      metrics: metrics,
      palette: palette,
      opacity: opacity,
    );
    _paintSparks(
      canvas,
      start: start,
      end: end,
      metrics: metrics,
      palette: palette,
      reveal: reveal,
      opacity: opacity,
    );
  }

  void _paintAura(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required WinningBeamMetrics metrics,
    required WinningBeamPalette palette,
    required double opacity,
    required double flare,
  }) {
    final outerGlow = Paint()
      ..shader = ui.Gradient.linear(
        start,
        end,
        [
          Colors.transparent,
          palette.halo.withValues(alpha: 0.34 * opacity),
          palette.bright.withValues(alpha: 0.68 * opacity),
          palette.halo.withValues(alpha: 0.34 * opacity),
          Colors.transparent,
        ],
        const [0, 0.22, 0.5, 0.78, 1],
      )
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(24, metrics.cellExtent * 0.3)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        math.max(14, metrics.cellExtent * (0.14 + flare * 0.06)),
      );
    final innerGlow = Paint()
      ..shader = ui.Gradient.linear(
        start,
        end,
        [
          Colors.transparent,
          palette.dim.withValues(alpha: 0.48 * opacity),
          palette.mid.withValues(alpha: 0.92 * opacity),
          palette.dim.withValues(alpha: 0.48 * opacity),
          Colors.transparent,
        ],
        const [0, 0.16, 0.5, 0.84, 1],
      )
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(10, metrics.cellExtent * 0.11)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.5);

    canvas.drawLine(start, end, outerGlow);
    canvas.drawLine(start, end, innerGlow);
  }

  void _paintCore(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required WinningBeamMetrics metrics,
    required WinningBeamPalette palette,
    required double opacity,
  }) {
    final core = Paint()
      ..shader = ui.Gradient.linear(
        start,
        end,
        [
          Colors.transparent,
          palette.dim.withValues(alpha: 0.78 * opacity),
          palette.core.withValues(alpha: opacity),
          palette.mid.withValues(alpha: 0.88 * opacity),
          Colors.transparent,
        ],
        const [0, 0.22, 0.5, 0.78, 1],
      )
      ..strokeCap = StrokeCap.round;

    final rim = Paint()
      ..color = AppPalette.shadow.withValues(alpha: 0.28 * opacity)
      ..strokeCap = StrokeCap.round;
    final glint = Paint()
      ..color = AppPalette.ivoryText.withValues(alpha: 0.72 * opacity)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);
    final rimOffset = metrics.normal * metrics.cellExtent * 0.028;

    canvas.drawLine(
      start - rimOffset,
      end - rimOffset,
      rim..strokeWidth = math.max(1, metrics.cellExtent * 0.012),
    );
    canvas.drawLine(
      start + rimOffset,
      end + rimOffset,
      rim..strokeWidth = math.max(1, metrics.cellExtent * 0.01),
    );
    canvas.drawLine(
      start,
      end,
      core..strokeWidth = math.max(4.4, metrics.cellExtent * 0.045),
    );
    canvas.drawLine(
      start + metrics.normal * metrics.cellExtent * 0.016,
      end + metrics.normal * metrics.cellExtent * 0.016,
      glint..strokeWidth = math.max(1.6, metrics.cellExtent * 0.016),
    );
  }

  void _paintSparks(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required WinningBeamMetrics metrics,
    required WinningBeamPalette palette,
    required double reveal,
    required double opacity,
  }) {
    final sparkOpacity =
        ((reveal - 0.42) / 0.58).clamp(0.0, 1.0).toDouble() * opacity;
    if (sparkOpacity == 0) {
      return;
    }

    final spark = Paint()
      ..color = palette.core.withValues(alpha: 0.82 * sparkOpacity)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.3, metrics.cellExtent * 0.014)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final ember = Paint()
      ..color = palette.bright.withValues(alpha: 0.68 * sparkOpacity);
    final span = end - start;

    for (var index = 0; index < 14; index++) {
      final t = 0.08 + index * 0.064;
      final side = index.isEven ? 1.0 : -1.0;
      final drift = math.sin(index * 1.7) * metrics.cellExtent * 0.05;
      final along = start + span * t;
      final point =
          along + metrics.normal * (side * metrics.cellExtent * 0.105);
      final tail = metrics.direction * metrics.cellExtent * 0.06;

      canvas.drawLine(point - tail, point + tail * 0.35, spark);
      canvas.drawCircle(
        point + metrics.normal * drift,
        metrics.cellExtent * (index.isEven ? 0.016 : 0.011),
        ember,
      );
    }
  }
}
