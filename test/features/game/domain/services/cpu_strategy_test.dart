import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/minimax_cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/random_cpu_strategy.dart';

void main() {
  Board boardWith(List<Cell> cells) => Board(cells: cells);

  group('RandomCpuStrategy', () {
    test('selects a playable cell', () {
      final strategy = RandomCpuStrategy(random: Random(1));
      final board = boardWith([
        Cell.human,
        Cell.cpu,
        Cell.human,
        Cell.cpu,
        Cell.human,
        Cell.cpu,
        Cell.human,
        Cell.cpu,
        Cell.empty,
      ]);

      expect(strategy.chooseMove(board, Player.cpu), 8);
    });
  });

  group('MinimaxCpuStrategy', () {
    const strategy = MinimaxCpuStrategy();

    test('does not miss a forced win', () {
      final board = boardWith([
        Cell.cpu,
        Cell.cpu,
        Cell.empty,
        Cell.human,
        Cell.human,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ]);

      expect(strategy.chooseMove(board, Player.cpu), 2);
    });

    test('blocks a forced human win', () {
      final board = boardWith([
        Cell.human,
        Cell.human,
        Cell.empty,
        Cell.empty,
        Cell.cpu,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ]);

      expect(strategy.chooseMove(board, Player.cpu), 2);
    });
  });
}
