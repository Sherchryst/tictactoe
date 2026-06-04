import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/boss_pattern_catalog.dart';
import 'package:tictactoe/features/game/domain/usecases/play_cpu_turn.dart';
import 'package:tictactoe/features/game/domain/usecases/play_human_move.dart';

void main() {
  const playHuman = PlayHumanMove();
  final playCpu = PlayCpuTurn();

  const patterns = BossPatterns.all;

  group('Boss puzzle CPU strategy', () {
    test('roster has unique patterns through NG+4', () {
      expect(patterns, hasLength(15));
      expect({
        for (final pattern in patterns) (pattern.bossId, pattern.noMercyCycle),
      }, hasLength(patterns.length));
      expect({
        for (final pattern in patterns) pattern.humanMoves.join(','),
      }, hasLength(patterns.length));
      expect(
        {for (final pattern in patterns) pattern.noMercyCycle},
        {0, 1, 2, 3, 4},
      );
    });

    for (final pattern in patterns) {
      test('${pattern.debugName} has one max-length winning sequence', () {
        var session = GameSession.newGame(
          GameSetup.noMercy(pattern.bossId, noMercyCycle: pattern.noMercyCycle),
        );

        expect(pattern.humanMoves, hasLength(5));
        expect(pattern.cpuMoves, hasLength(4));

        for (var index = 0; index < pattern.humanMoves.length; index++) {
          session = playHuman(session, pattern.humanMoves[index]);
          expect(session.weaknessBroken, isFalse);

          if (session.result.isOngoing) {
            session = playCpu(session);
          }
        }

        expect(session.humanMoves, pattern.humanMoves);
        expect(session.cpuMoves, pattern.cpuMoves);
        final result = session.result;
        expect(result, isA<GameWin>());
        final win = result as GameWin;
        expect(win.winner, Mark.x);
        expect(win.winningCells, hasLength(3));
        expect(pattern.humanMoves, containsAll(win.winningCells));
      });
    }

    for (final pattern in patterns) {
      test('${pattern.debugName} deviation locks out human victory', () {
        final wrongMove = pattern.humanMoves.first == 0 ? 1 : 0;
        var session = playHuman(
          GameSession.newGame(
            GameSetup.noMercy(
              pattern.bossId,
              noMercyCycle: pattern.noMercyCycle,
            ),
          ),
          wrongMove,
        );

        expect(session.weaknessBroken, isTrue);
        expect(session.humanMoves, [wrongMove]);

        while (session.result.isOngoing &&
            session.board.emptyCells.isNotEmpty) {
          if (session.canHumanPlay) {
            session = playHuman(session, session.board.emptyCells.first);
          } else {
            session = playCpu(session);
          }
        }

        expect(session.participantOutcome, isNot(GameOutcome.humanWin));
      });
    }
  });
}
