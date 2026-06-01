import 'package:freezed_annotation/freezed_annotation.dart';

import 'cell.dart';
import 'game_domain_messages.dart';

part 'board.freezed.dart';

@freezed
abstract class Board with _$Board {
  const Board._();

  const factory Board({required List<Cell> cells}) = _Board;

  factory Board.empty() {
    return const Board(
      cells: [
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ],
    );
  }

  static const size = 3;
  static const cellCount = size * size;

  bool get isFull => !cells.contains(Cell.empty);

  List<int> get emptyCells {
    return [
      for (var index = 0; index < cells.length; index++)
        if (cells[index].isEmpty) index,
    ];
  }

  bool canPlace(int index) {
    return index >= 0 && index < cellCount && cells[index].isEmpty;
  }

  Cell cellAt(int index) {
    RangeError.checkValidIndex(index, cells);
    return cells[index];
  }

  Board place(Cell cell, int index) {
    if (!canPlace(index)) {
      throw StateError(GameDomainMessages.cellNotPlayable(index));
    }

    final nextCells = List<Cell>.of(cells);
    nextCells[index] = cell;
    return copyWith(cells: nextCells);
  }
}
