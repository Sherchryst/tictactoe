import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/usecases/play_move.dart';

void main() {
  const playMove = PlayMove();

  GameSession freshSession() {
    return GameSession.newGame(GameSetup.guidedTrial());
  }

  group('PlayMove', () {
    test('rejects an out-of-range cell', () {
      final session = freshSession();

      expect(playMove(session, Mark.x, -1), session);
      expect(playMove(session, Mark.x, Board.cellCount), session);
    });

    test('rejects an already-occupied cell', () {
      final session = freshSession();
      final occupied = playMove(session, Mark.x, 0);

      expect(playMove(occupied, Mark.o, 0), occupied);
    });

    test('places the mark and switches the current mark', () {
      final session = freshSession();

      final next = playMove(session, Mark.x, 4);

      expect(next.board.markAt(4), Mark.x);
      expect(next.currentMark, Mark.o);
      expect(next.result.isOngoing, isTrue);
    });

    test('rejects a move from the wrong mark', () {
      final session = freshSession();

      expect(playMove(session, Mark.o, 4), session);
    });

    test('rejects a move when the game is already decided', () {
      final session = freshSession().copyWith(result: const GameResult.draw());

      expect(playMove(session, Mark.x, 4), session);
    });

    test('reports the win when the move closes a line', () {
      final session = GameSession(
        board: Board(
          cells: [Mark.x, Mark.x, null, Mark.o, Mark.o, null, null, null, null],
        ),
        currentMark: Mark.x,
        bossId: CpuBossId.guided,
        result: const GameResult.ongoing(),
      );

      final next = playMove(session, Mark.x, 2);

      expect(
        next.result,
        const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
      );
      expect(next.currentMark, Mark.x);
    });
  });
}
