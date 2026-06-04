import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy_resolver.dart';
import 'package:tictactoe/features/game/domain/usecases/play_cpu_turn.dart';

import '../../../../testing/mock_stubs.dart';
import '../../../../testing/mocks.mocks.dart';

PlayCpuTurn _useCase(MockCpuStrategy strategy) {
  final resolver = CpuStrategyResolver(
    guidedStrategy: strategy,
    noMercyStrategy: strategy,
  );

  return PlayCpuTurn(strategyResolver: resolver);
}

void main() {
  group('PlayCpuTurn', () {
    test('does nothing when it is the human turn', () {
      final strategy = MockCpuStrategy();
      stubCpuStrategy(strategy, move: 4);
      final useCase = _useCase(strategy);
      final session = GameSession.newGame(GameSetup.guidedTrial());

      expect(useCase(session), session);
      verifyNever(strategy.chooseMove(any));
    });

    test('does nothing in local duel mode', () {
      final strategy = MockCpuStrategy();
      stubCpuStrategy(strategy, move: 4);
      final useCase = _useCase(strategy);
      final session = GameSession.newGame(
        GameSetup.localDuel(),
      ).copyWith(currentMark: Mark.o);

      expect(useCase(session), session);
      verifyNever(strategy.chooseMove(any));
    });

    test('plays the cpu move when it is the cpu turn', () {
      final strategy = MockCpuStrategy();
      stubCpuStrategy(strategy, move: 4);
      final useCase = _useCase(strategy);
      final session = GameSession.newGame(
        GameSetup.guidedTrial(),
      ).copyWith(currentMark: Mark.o);

      final next = useCase(session);

      expect(next.board.markAt(4), Mark.o);
      expect(next.currentMark, Mark.x);
      expect(next.cpuMoves, [4]);
      verify(strategy.chooseMove(session)).called(1);
    });

    test('does not play when the result is decided', () {
      final strategy = MockCpuStrategy();
      stubCpuStrategy(strategy, move: 4);
      final useCase = _useCase(strategy);
      final session = GameSession(
        board: Board.empty(),
        currentMark: Mark.o,
        bossId: CpuBossId.guided,
        result: const GameResult.draw(),
      );

      expect(useCase(session), session);
      verifyNever(strategy.chooseMove(any));
    });
  });
}
