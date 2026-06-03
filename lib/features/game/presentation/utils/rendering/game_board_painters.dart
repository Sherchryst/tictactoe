import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';

class BoardGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final inset = Paint()
      ..color = AppPalette.shadow.withValues(alpha: AppAlphas.strong)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.5;
    final groove = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;
    final sheen = Paint()
      ..color = AppPalette.goldBright.withValues(alpha: AppAlphas.muted)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.8;

    for (var index = 1; index < Board.size; index++) {
      final position = size.width * index / Board.size;
      final inlay = size.width * 0.06;
      final verticalStart = Offset(position, inlay);
      final verticalEnd = Offset(position, size.height - inlay);
      final horizontalStart = Offset(inlay, position);
      final horizontalEnd = Offset(size.width - inlay, position);

      groove.shader = LinearGradient(
        colors: [
          AppPalette.goldDim.withValues(alpha: AppAlphas.faint),
          AppPalette.gold.withValues(alpha: AppAlphas.prominent),
          AppPalette.goldDim.withValues(alpha: AppAlphas.faint),
        ],
      ).createShader(Rect.fromPoints(verticalStart, horizontalEnd));

      canvas.drawLine(verticalStart, verticalEnd, inset);
      canvas.drawLine(horizontalStart, horizontalEnd, inset);
      canvas.drawLine(verticalStart, verticalEnd, groove);
      canvas.drawLine(horizontalStart, horizontalEnd, groove);
      canvas.drawLine(
        verticalStart.translate(1, 0),
        verticalEnd.translate(1, 0),
        sheen,
      );
      canvas.drawLine(
        horizontalStart.translate(0, 1),
        horizontalEnd.translate(0, 1),
        sheen,
      );
    }

    for (var row = 1; row < Board.size; row++) {
      for (var column = 1; column < Board.size; column++) {
        _paintNode(
          canvas,
          Offset(size.width * column / 3, size.height * row / 3),
          size.shortestSide * 0.018,
        );
      }
    }
  }

  void _paintNode(Canvas canvas, Offset center, double radius) {
    final halo = Paint()
      ..color = AppPalette.gold.withValues(alpha: AppAlphas.medium)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final diamond = Path()
      ..moveTo(center.dx, center.dy - radius * 1.4)
      ..lineTo(center.dx + radius * 1.1, center.dy)
      ..lineTo(center.dx, center.dy + radius * 1.4)
      ..lineTo(center.dx - radius * 1.1, center.dy)
      ..close();
    final orb = Paint()..color = AppPalette.goldBright.withValues(alpha: 0.92);
    final core = Paint()..color = AppPalette.ivoryText;

    canvas.drawCircle(center, radius * 2.6, halo);
    canvas.drawPath(diamond, orb);
    canvas.drawCircle(center, radius * 0.42, core);
  }

  @override
  bool shouldRepaint(covariant BoardGridPainter oldDelegate) => false;
}

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

class WinningBeamPainter extends CustomPainter {
  const WinningBeamPainter({
    required this.winningCells,
    required this.winner,
    required this.progress,
  });

  final List<int> winningCells;
  final Player winner;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    if (clampedProgress == 0 || winningCells.length < 3) {
      return;
    }

    final metrics = _WinningBeamMetrics.from(size, winningCells);
    if (metrics == null) {
      return;
    }

    final palette = _BeamPalette.forWinner(winner);
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
    required _WinningBeamMetrics metrics,
    required _BeamPalette palette,
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
    required _WinningBeamMetrics metrics,
    required _BeamPalette palette,
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
    required _WinningBeamMetrics metrics,
    required _BeamPalette palette,
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

  @override
  bool shouldRepaint(covariant WinningBeamPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.winner != winner ||
        !_sameCells(oldDelegate.winningCells, winningCells);
  }

  bool _sameCells(List<int> previous, List<int> next) {
    if (previous.length != next.length) {
      return false;
    }

    for (var index = 0; index < previous.length; index++) {
      if (previous[index] != next[index]) {
        return false;
      }
    }

    return true;
  }
}

class _WinningBeamMetrics {
  const _WinningBeamMetrics._({
    required this.start,
    required this.end,
    required this.center,
    required this.direction,
    required this.normal,
    required this.cellExtent,
  });

  final Offset start;
  final Offset end;
  final Offset center;
  final Offset direction;
  final Offset normal;
  final double cellExtent;

  Offset get span => end - start;

  static _WinningBeamMetrics? from(Size size, List<int> winningCells) {
    final orderedCells = _orderedCells(winningCells);
    Offset centerFor(int index) {
      final row = index ~/ Board.size;
      final column = index % Board.size;

      return Offset(
        (column + 0.5) * size.width / Board.size,
        (row + 0.5) * size.height / Board.size,
      );
    }

    final rawStart = centerFor(orderedCells.first);
    final rawEnd = centerFor(orderedCells.last);
    final vector = rawEnd - rawStart;
    final length = vector.distance;
    if (length == 0) {
      return null;
    }

    final direction = Offset(vector.dx / length, vector.dy / length);
    final normal = Offset(-direction.dy, direction.dx);
    final cellExtent = math.min(size.width, size.height) / Board.size;
    final extension = cellExtent * 0.43;
    final start = rawStart - direction * extension;
    final end = rawEnd + direction * extension;

    return _WinningBeamMetrics._(
      start: start,
      end: end,
      center: (start + end) / 2,
      direction: direction,
      normal: normal,
      cellExtent: cellExtent,
    );
  }

  static List<int> _orderedCells(List<int> cells) {
    return List<int>.of(cells)..sort((first, second) {
      final firstRow = first ~/ Board.size;
      final secondRow = second ~/ Board.size;
      if (firstRow != secondRow) {
        return firstRow.compareTo(secondRow);
      }

      final firstColumn = first % Board.size;
      final secondColumn = second % Board.size;
      return firstColumn.compareTo(secondColumn);
    });
  }
}

class _BeamPalette {
  const _BeamPalette({
    required this.bright,
    required this.mid,
    required this.dim,
    required this.halo,
    required this.core,
  });

  factory _BeamPalette.forWinner(Player winner) {
    return switch (winner) {
      Player.human => const _BeamPalette(
        bright: AppPalette.goldBright,
        mid: AppPalette.gold,
        dim: AppPalette.goldDim,
        halo: AppPalette.gold,
        core: AppPalette.ivoryText,
      ),
      Player.cpu => const _BeamPalette(
        bright: Color(0xffd8323d),
        mid: AppPalette.lossRed,
        dim: AppPalette.lossRedDeep,
        halo: AppPalette.lossRed,
        core: Color(0xffffc0a8),
      ),
    };
  }

  final Color bright;
  final Color mid;
  final Color dim;
  final Color halo;
  final Color core;
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
