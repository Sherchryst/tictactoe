import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/game_rules.dart';

void main() {
  const rules = GameRules();

  Board boardWith(List<Mark?> cells) => Board(cells: cells);

  group('GameRules', () {
    test('detects a row win', () {
      final result = rules.evaluate(
        boardWith([
          Mark.x,
          Mark.x,
          Mark.x,
          null,
          Mark.o,
          null,
          Mark.o,
          null,
          null,
        ]),
      );

      expect(
        result,
        const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
      );
    });

    test('detects a column win', () {
      final result = rules.evaluate(
        boardWith([
          Mark.o,
          Mark.x,
          null,
          Mark.o,
          Mark.x,
          null,
          Mark.o,
          null,
          Mark.x,
        ]),
      );

      expect(
        result,
        const GameResult.win(winner: Mark.o, winningCells: [0, 3, 6]),
      );
    });

    test('detects a diagonal win', () {
      final result = rules.evaluate(
        boardWith([
          Mark.x,
          Mark.o,
          null,
          Mark.o,
          Mark.x,
          null,
          null,
          null,
          Mark.x,
        ]),
      );

      expect(
        result,
        const GameResult.win(winner: Mark.x, winningCells: [0, 4, 8]),
      );
    });

    test('detects a draw', () {
      final result = rules.evaluate(
        boardWith([
          Mark.x,
          Mark.o,
          Mark.x,
          Mark.x,
          Mark.o,
          Mark.o,
          Mark.o,
          Mark.x,
          Mark.x,
        ]),
      );

      expect(result, const GameResult.draw());
    });

    test('keeps an unfinished board ongoing', () {
      final result = rules.evaluate(
        boardWith([Mark.x, Mark.o, null, null, null, null, null, null, null]),
      );

      expect(result, const GameResult.ongoing());
    });
  });
}
