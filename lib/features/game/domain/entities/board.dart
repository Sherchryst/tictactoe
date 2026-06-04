import 'package:tictactoe/features/game/domain/entities/game_domain_messages.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';

final class Board {
  factory Board({required List<Mark?> cells}) {
    if (cells.length != cellCount) {
      throw ArgumentError.value(
        cells.length,
        'cells.length',
        GameDomainMessages.boardMustContainNineCells,
      );
    }

    return Board._(List<Mark?>.unmodifiable(cells));
  }

  const Board._(this.cells);

  factory Board.empty() {
    return Board(
      cells: const [null, null, null, null, null, null, null, null, null],
    );
  }

  static const size = 3;
  static const cellCount = size * size;

  final List<Mark?> cells;

  bool get isFull => !cells.contains(null);

  List<int> get emptyCells {
    return [
      for (var index = 0; index < cells.length; index++)
        if (cells[index] == null) index,
    ];
  }

  bool canPlace(int index) {
    return index >= 0 && index < cells.length && cells[index] == null;
  }

  Mark? markAt(int index) {
    RangeError.checkValidIndex(index, cells, 'index', cellCount);
    return cells[index];
  }

  Board place(Mark mark, int index) {
    if (!canPlace(index)) {
      throw StateError(GameDomainMessages.cellNotPlayable(index));
    }

    final nextCells = List<Mark?>.of(cells);
    nextCells[index] = mark;
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

  static bool _sameCells(List<Mark?> first, List<Mark?> second) {
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
