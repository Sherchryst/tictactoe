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

import 'package:tictactoe/testing/mock_stubs.dart';
import 'package:tictactoe/testing/mocks.mocks.dart';

PlayCpuTurn _useCase(MockCpuStrategy strategy) {
  final resolver = CpuStrategyResolver(
    easyStrategy: strategy,
    hardStrategy: strategy,
  );

  return PlayCpuTurn(strategyResolver: resolver);
}

void main() {
  group('PlayCpuTurn', () {
    test('does nothing when it is the human turn', () {
      final strategy = MockCpuStrategy();
      stubCpuStrategy(strategy, move: 4);
      final useCase = _useCase(strategy);
      final session = GameSession.newGame(const GameSetup());

      expect(useCase(session), session);
      verifyNever(strategy.chooseMove(any, any));
    });

    test('does nothing in two-player mode', () {
      final strategy = MockCpuStrategy();
      stubCpuStrategy(strategy, move: 4);
      final useCase = _useCase(strategy);
      final session = GameSession.newGame(
        const GameSetup(mode: GameMode.humanVsHuman),
      ).copyWith(currentPlayer: Player.cpu);

      expect(useCase(session), session);
      verifyNever(strategy.chooseMove(any, any));
    });

    test('plays the cpu move when it is the cpu turn', () {
      final strategy = MockCpuStrategy();
      stubCpuStrategy(strategy, move: 4);
      final useCase = _useCase(strategy);
      final session = GameSession.newGame(
        const GameSetup(),
      ).copyWith(currentPlayer: Player.cpu);

      final next = useCase(session);

      expect(next.board.cellAt(4), Cell.cpu);
      expect(next.currentPlayer, Player.human);
      verify(strategy.chooseMove(session.board, Player.cpu)).called(1);
    });

    test('does not play when the result is decided', () {
      final strategy = MockCpuStrategy();
      stubCpuStrategy(strategy, move: 4);
      final useCase = _useCase(strategy);
      final session = GameSession(
        board: Board.empty(),
        currentPlayer: Player.cpu,
        difficulty: GameDifficulty.easy,
        result: const GameResult.draw(),
      );

      expect(useCase(session), session);
      verifyNever(strategy.chooseMove(any, any));
    });
  });
}
