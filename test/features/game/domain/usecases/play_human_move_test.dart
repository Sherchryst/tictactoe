import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy_resolver.dart';
import 'package:tictactoe/features/game/domain/usecases/play_cpu_turn.dart';
import 'package:tictactoe/features/game/domain/usecases/play_human_move.dart';

import '../../../../testing/mock_stubs.dart';
import '../../../../testing/mocks.mocks.dart';

_Harness _harness({int cpuMove = 8}) {
  final strategy = MockCpuStrategy();
  stubCpuStrategy(strategy, move: cpuMove);
  final resolver = CpuStrategyResolver(
    easyStrategy: strategy,
    hardStrategy: strategy,
  );

  return _Harness(
    strategy: strategy,
    useCase: PlayHumanMove(
      playCpuTurn: PlayCpuTurn(strategyResolver: resolver),
    ),
  );
}

void main() {
  group('PlayHumanMove', () {
    test('keeps the session unchanged when the cell is not playable', () {
      final harness = _harness();
      final session = GameSession.newGame(
        const GameSetup(difficulty: GameDifficulty.easy),
      );

      expect(harness.useCase(session, -1), session);
      verifyNever(harness.strategy.chooseMove(any, any));
    });

    test('plays the human move then the cpu move', () {
      final harness = _harness();
      final session = GameSession.newGame(
        const GameSetup(difficulty: GameDifficulty.easy),
      );

      final nextSession = harness.useCase(session, 0);

      expect(nextSession.board.cellAt(0), Cell.human);
      expect(nextSession.board.cellAt(8), Cell.cpu);
      expect(nextSession.currentPlayer, Player.human);
      expect(nextSession.result, const GameResult.ongoing());
      verify(harness.strategy.chooseMove(any, Player.cpu)).called(1);
    });

    test('alternates local players without playing a cpu move', () {
      final harness = _harness();
      final session = GameSession.newGame(
        const GameSetup(mode: GameMode.humanVsHuman),
      );

      final afterFirstMove = harness.useCase(session, 0);
      final afterSecondMove = harness.useCase(afterFirstMove, 1);

      expect(afterFirstMove.board.cellAt(0), Cell.human);
      expect(afterFirstMove.board.cellAt(8), Cell.empty);
      expect(afterFirstMove.currentPlayer, Player.cpu);
      expect(afterSecondMove.board.cellAt(1), Cell.cpu);
      expect(afterSecondMove.currentPlayer, Player.human);
      verifyNever(harness.strategy.chooseMove(any, any));
    });

    test('does not play the cpu when the human wins', () {
      final harness = _harness();
      final session = GameSession(
        board: Board(
          cells: [
            Cell.human,
            Cell.human,
            Cell.empty,
            Cell.cpu,
            Cell.cpu,
            Cell.empty,
            Cell.empty,
            Cell.empty,
            Cell.empty,
          ],
        ),
        currentPlayer: Player.human,
        difficulty: GameDifficulty.easy,
        result: const GameResult.ongoing(),
      );

      final nextSession = harness.useCase(session, 2);

      expect(
        nextSession.result,
        const GameResult.win(winner: Player.human, winningCells: [0, 1, 2]),
      );
      expect(nextSession.board.cellAt(8), Cell.empty);
      verifyNever(harness.strategy.chooseMove(any, any));
    });

    test('lets the cpu finish the game after a human move', () {
      final harness = _harness(cpuMove: 2);
      final session = GameSession(
        board: Board(
          cells: [
            Cell.cpu,
            Cell.cpu,
            Cell.empty,
            Cell.human,
            Cell.human,
            Cell.empty,
            Cell.empty,
            Cell.empty,
            Cell.empty,
          ],
        ),
        currentPlayer: Player.human,
        difficulty: GameDifficulty.easy,
        result: const GameResult.ongoing(),
      );

      final nextSession = harness.useCase(session, 8);

      expect(
        nextSession.result,
        const GameResult.win(winner: Player.cpu, winningCells: [0, 1, 2]),
      );
      verify(harness.strategy.chooseMove(any, Player.cpu)).called(1);
    });
  });
}

final class _Harness {
  const _Harness({required this.strategy, required this.useCase});

  final MockCpuStrategy strategy;
  final PlayHumanMove useCase;
}
