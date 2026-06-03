import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';

void main() {
  group('Board', () {
    test('accepts exactly nine cells', () {
      final board = Board(cells: List.filled(Board.cellCount, Cell.empty));

      expect(board.cells, hasLength(Board.cellCount));
      expect(board.canPlace(0), isTrue);
    });

    test('rejects boards with an invalid cell count', () {
      expect(
        () => Board(cells: List.filled(Board.cellCount - 1, Cell.empty)),
        throwsArgumentError,
      );
      expect(
        () => Board(cells: List.filled(Board.cellCount + 1, Cell.empty)),
        throwsArgumentError,
      );
    });
  });
}
