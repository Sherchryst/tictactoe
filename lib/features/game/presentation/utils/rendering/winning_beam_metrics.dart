import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';

class WinningBeamMetrics {
  const WinningBeamMetrics._({
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

  static WinningBeamMetrics? from(Size size, List<int> winningCells) {
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

    return WinningBeamMetrics._(
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
