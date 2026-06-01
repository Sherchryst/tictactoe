import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/minimax_cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/random_cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/tactical_cpu_strategy.dart';

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

  group('TacticalCpuStrategy', () {
    const strategy = TacticalCpuStrategy();

    test('wins immediately when possible', () {
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

    test('blocks the opponent immediate win', () {
      final board = boardWith([
        Cell.human,
        Cell.human,
        Cell.empty,
        Cell.cpu,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ]);

      expect(strategy.chooseMove(board, Player.cpu), 2);
    });

    test('takes the center before corners and sides', () {
      expect(strategy.chooseMove(Board.empty(), Player.cpu), 4);
    });

    test('takes a corner before a side', () {
      final board = boardWith([
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.human,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ]);

      expect(strategy.chooseMove(board, Player.cpu), 0);
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
