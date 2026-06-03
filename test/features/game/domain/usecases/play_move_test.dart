import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/usecases/play_move.dart';

void main() {
  const playMove = PlayMove();

  GameSession freshSession() {
    return GameSession.newGame(const GameSetup());
  }

  group('PlayMove', () {
    test('rejects an out-of-range cell', () {
      final session = freshSession();

      expect(playMove(session, Player.human, -1), session);
      expect(playMove(session, Player.human, Board.cellCount), session);
    });

    test('rejects an already-occupied cell', () {
      final session = freshSession();
      final occupied = playMove(session, Player.human, 0);

      expect(playMove(occupied, Player.cpu, 0), occupied);
    });

    test('places the mark and switches the current player', () {
      final session = freshSession();

      final next = playMove(session, Player.human, 4);

      expect(next.board.cellAt(4), Cell.human);
      expect(next.currentPlayer, Player.cpu);
      expect(next.result.isOngoing, isTrue);
    });

    test('rejects a move from the wrong player', () {
      final session = freshSession();

      expect(playMove(session, Player.cpu, 4), session);
    });

    test('rejects a move when the game is already decided', () {
      final session = freshSession().copyWith(result: const GameResult.draw());

      expect(playMove(session, Player.human, 4), session);
    });

    test('reports the win when the move closes a line', () {
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
        difficulty: GameDifficulty.hard,
        result: const GameResult.ongoing(),
      );

      final next = playMove(session, Player.human, 2);

      expect(
        next.result,
        const GameResult.win(winner: Player.human, winningCells: [0, 1, 2]),
      );
      expect(next.currentPlayer, Player.human);
    });
  });
}
