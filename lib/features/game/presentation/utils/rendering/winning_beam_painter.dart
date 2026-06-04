import 'package:flutter/material.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/presentation/utils/rendering/winning_beam_renderer.dart';

class WinningBeamPainter extends CustomPainter {
  const WinningBeamPainter({
    required this.winningCells,
    required this.winner,
    required this.progress,
  });

  static const _renderer = WinningBeamRenderer();

  final List<int> winningCells;
  final Mark winner;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _renderer.paint(
      canvas: canvas,
      size: size,
      winningCells: winningCells,
      winner: winner,
      progress: progress,
    );
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
