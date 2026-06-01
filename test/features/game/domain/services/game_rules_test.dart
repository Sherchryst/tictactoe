import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/game_rules.dart';

void main() {
  const rules = GameRules();

  Board boardWith(List<Cell> cells) => Board(cells: cells);

  group('GameRules', () {
    test('detects a row win', () {
      final result = rules.evaluate(
        boardWith([
          Cell.human,
          Cell.human,
          Cell.human,
          Cell.empty,
          Cell.cpu,
          Cell.empty,
          Cell.cpu,
          Cell.empty,
          Cell.empty,
        ]),
      );

      expect(
        result,
        const GameResult.win(winner: Player.human, winningCells: [0, 1, 2]),
      );
    });

    test('detects a column win', () {
      final result = rules.evaluate(
        boardWith([
          Cell.cpu,
          Cell.human,
          Cell.empty,
          Cell.cpu,
          Cell.human,
          Cell.empty,
          Cell.cpu,
          Cell.empty,
          Cell.human,
        ]),
      );

      expect(
        result,
        const GameResult.win(winner: Player.cpu, winningCells: [0, 3, 6]),
      );
    });

    test('detects a diagonal win', () {
      final result = rules.evaluate(
        boardWith([
          Cell.human,
          Cell.cpu,
          Cell.empty,
          Cell.cpu,
          Cell.human,
          Cell.empty,
          Cell.empty,
          Cell.empty,
          Cell.human,
        ]),
      );

      expect(
        result,
        const GameResult.win(winner: Player.human, winningCells: [0, 4, 8]),
      );
    });

    test('detects a draw', () {
      final result = rules.evaluate(
        boardWith([
          Cell.human,
          Cell.cpu,
          Cell.human,
          Cell.human,
          Cell.cpu,
          Cell.cpu,
          Cell.cpu,
          Cell.human,
          Cell.human,
        ]),
      );

      expect(result, const GameResult.draw());
    });

    test('keeps an unfinished board ongoing', () {
      final result = rules.evaluate(
        boardWith([
          Cell.human,
          Cell.cpu,
          Cell.empty,
          Cell.empty,
          Cell.empty,
          Cell.empty,
          Cell.empty,
          Cell.empty,
          Cell.empty,
        ]),
      );

      expect(result, const GameResult.ongoing());
    });
  });
}
