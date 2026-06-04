import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/boss_pattern_catalog.dart';
import 'package:tictactoe/features/game/domain/usecases/play_human_move.dart';

void main() {
  const useCase = PlayHumanMove();

  group('PlayHumanMove', () {
    test('keeps the session unchanged when the cell is not playable', () {
      final session = GameSession.newGame(GameSetup.guidedTrial());

      expect(useCase(session, -1), session);
    });

    test('plays only the human move in guided mode', () {
      final session = GameSession.newGame(GameSetup.guidedTrial());

      final nextSession = useCase(session, 0);

      expect(nextSession.board.markAt(0), Mark.x);
      expect(nextSession.currentMark, Mark.o);
      expect(nextSession.humanMoves, [0]);
      expect(nextSession.cpuMoves, isEmpty);
      expect(nextSession.result, const GameResult.ongoing());
    });

    test('alternates local players without recording cpu puzzle moves', () {
      final session = GameSession.newGame(GameSetup.localDuel());

      final afterFirstMove = useCase(session, 0);
      final afterSecondMove = useCase(afterFirstMove, 1);

      expect(afterFirstMove.board.markAt(0), Mark.x);
      expect(afterFirstMove.currentMark, Mark.o);
      expect(afterFirstMove.humanMoves, isEmpty);
      expect(afterSecondMove.board.markAt(1), Mark.o);
      expect(afterSecondMove.currentMark, Mark.x);
    });

    test('keeps weakness intact while the No Mercy prefix matches', () {
      final session = GameSession.newGame(GameSetup.noMercy(CpuBossId.radahn));

      final nextSession = useCase(
        session,
        BossPatterns.radahn.humanMoves.first,
      );

      expect(nextSession.weaknessBroken, isFalse);
      expect(nextSession.humanMoves, [BossPatterns.radahn.humanMoves.first]);
    });

    test('breaks the weakness when the No Mercy prefix deviates', () {
      final session = GameSession.newGame(GameSetup.noMercy(CpuBossId.radahn));
      final wrongMove = BossPatterns.radahn.humanMoves.first == 0 ? 1 : 0;

      final nextSession = useCase(session, wrongMove);

      expect(nextSession.weaknessBroken, isTrue);
      expect(nextSession.humanMoves, [wrongMove]);
    });
  });
}
