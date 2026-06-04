import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';

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
