import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/game_domain_messages.dart';

final class Board {
  factory Board({required List<Cell> cells}) {
    if (cells.length != cellCount) {
      throw ArgumentError.value(
        cells.length,
        'cells.length',
        GameDomainMessages.boardMustContainNineCells,
      );
    }

    return Board._(List<Cell>.unmodifiable(cells));
  }

  const Board._(this.cells);

  factory Board.empty() {
    return Board(
      cells: const [
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

  final List<Cell> cells;

  bool get isFull => !cells.contains(Cell.empty);

  List<int> get emptyCells {
    return [
      for (var index = 0; index < cells.length; index++)
        if (cells[index].isEmpty) index,
    ];
  }

  bool canPlace(int index) {
    return index >= 0 && index < cells.length && cells[index].isEmpty;
  }

  Cell cellAt(int index) {
    RangeError.checkValidIndex(index, cells, 'index', cellCount);
    return cells[index];
  }

  Board place(Cell cell, int index) {
    if (!canPlace(index)) {
      throw StateError(GameDomainMessages.cellNotPlayable(index));
    }

    final nextCells = List<Cell>.of(cells);
    nextCells[index] = cell;
    return Board(cells: nextCells);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Board && _sameCells(other.cells, cells);
  }

  @override
  int get hashCode => Object.hashAll(cells);

  @override
  String toString() => 'Board(cells: $cells)';

  static bool _sameCells(List<Cell> first, List<Cell> second) {
    if (first.length != second.length) {
      return false;
    }

    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }

    return true;
  }
}
