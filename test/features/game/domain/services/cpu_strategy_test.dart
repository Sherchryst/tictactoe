import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/minimax_cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/random_cpu_strategy.dart';

void main() {
  Board boardWith(List<Mark?> cells) => Board(cells: cells);

  GameSession sessionWith(Board board) {
    return GameSession(
      board: board,
      currentMark: Mark.o,
      bossId: CpuBossId.guided,
      result: const GameResult.ongoing(),
    );
  }

  group('RandomCpuStrategy', () {
    test('selects a playable cell', () {
      final strategy = RandomCpuStrategy(random: Random(1));
      final board = boardWith([
        Mark.x,
        Mark.o,
        Mark.x,
        Mark.o,
        Mark.x,
        Mark.o,
        Mark.x,
        Mark.o,
        null,
      ]);

      expect(strategy.chooseMove(sessionWith(board)), 8);
    });
  });

  group('MinimaxCpuStrategy', () {
    const strategy = MinimaxCpuStrategy();

    test('does not miss a forced win', () {
      final board = boardWith([
        Mark.o,
        Mark.o,
        null,
        Mark.x,
        Mark.x,
        null,
        null,
        null,
        null,
      ]);

      expect(strategy.chooseMove(sessionWith(board)), 2);
    });

    test('blocks a forced human win', () {
      final board = boardWith([
        Mark.x,
        Mark.x,
        null,
        null,
        Mark.o,
        null,
        null,
        null,
        null,
      ]);

      expect(strategy.chooseMove(sessionWith(board)), 2);
    });
  });
}
