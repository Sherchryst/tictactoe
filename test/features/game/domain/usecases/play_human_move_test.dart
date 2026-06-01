import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/game_difficulty.dart';
import 'package:tictactoe/features/game/domain/entities/game_mode.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_settings.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/usecases/play_human_move.dart';

void main() {
  group('PlayHumanMove', () {
    test('keeps the session unchanged when the cell is not playable', () {
      final useCase = PlayHumanMove(easyStrategy: const FixedCpuStrategy(8));
      final session = GameSession.newGame(
        const GameSettings(difficulty: GameDifficulty.easy),
      );

      expect(useCase(session, -1), session);
    });

    test('plays the human move then the cpu move', () {
      final useCase = PlayHumanMove(easyStrategy: const FixedCpuStrategy(8));
      final session = GameSession.newGame(
        const GameSettings(difficulty: GameDifficulty.easy),
      );

      final nextSession = useCase(session, 0);

      expect(nextSession.board.cellAt(0), Cell.human);
      expect(nextSession.board.cellAt(8), Cell.cpu);
      expect(nextSession.currentPlayer, Player.human);
      expect(nextSession.result, const GameResult.ongoing());
    });

    test('alternates local players without playing a cpu move', () {
      final useCase = PlayHumanMove(easyStrategy: const FixedCpuStrategy(8));
      final session = GameSession.newGame(
        const GameSettings(mode: GameMode.humanVsHuman),
      );

      final afterFirstMove = useCase(session, 0);
      final afterSecondMove = useCase(afterFirstMove, 1);

      expect(afterFirstMove.board.cellAt(0), Cell.human);
      expect(afterFirstMove.board.cellAt(8), Cell.empty);
      expect(afterFirstMove.currentPlayer, Player.cpu);
      expect(afterSecondMove.board.cellAt(1), Cell.cpu);
      expect(afterSecondMove.currentPlayer, Player.human);
    });

    test('does not play the cpu when the human wins', () {
      final useCase = PlayHumanMove(easyStrategy: const FixedCpuStrategy(8));
      final session = GameSession(
        board: const Board(
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

      final nextSession = useCase(session, 2);

      expect(
        nextSession.result,
        const GameResult.win(winner: Player.human, winningCells: [0, 1, 2]),
      );
      expect(nextSession.board.cellAt(8), Cell.empty);
    });

    test('lets the cpu finish the game after a human move', () {
      final useCase = PlayHumanMove(easyStrategy: const FixedCpuStrategy(2));
      final session = GameSession(
        board: const Board(
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

      final nextSession = useCase(session, 8);

      expect(
        nextSession.result,
        const GameResult.win(winner: Player.cpu, winningCells: [0, 1, 2]),
      );
    });
  });
}

final class FixedCpuStrategy implements CpuStrategy {
  const FixedCpuStrategy(this.move);

  final int move;

  @override
  int chooseMove(Board board, Player player) => move;
}
