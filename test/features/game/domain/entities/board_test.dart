import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';

void main() {
  group('Board', () {
    test('accepts exactly nine mark slots', () {
      final board = Board(cells: List.filled(Board.cellCount, null));

      expect(board.cells, hasLength(Board.cellCount));
      expect(board.canPlace(0), isTrue);
    });

    test('rejects boards with an invalid cell count', () {
      expect(
        () => Board(cells: List.filled(Board.cellCount - 1, null)),
        throwsArgumentError,
      );
      expect(
        () => Board(cells: List.filled(Board.cellCount + 1, null)),
        throwsArgumentError,
      );
    });

    test('places a mark immutably', () {
      final board = Board.empty();
      final next = board.place(Mark.x, 4);

      expect(board.markAt(4), isNull);
      expect(next.markAt(4), Mark.x);
      expect(next.emptyCells, isNot(contains(4)));
    });
  });
}
