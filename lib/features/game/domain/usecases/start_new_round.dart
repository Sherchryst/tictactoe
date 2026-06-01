import '../entities/board.dart';
import '../entities/game_result.dart';
import '../entities/game_session.dart';
import '../entities/player.dart';

final class StartNewRound {
  const StartNewRound();

  GameSession call(GameSession session) {
    return session.copyWith(
      board: Board.empty(),
      currentPlayer: Player.human,
      result: const GameResult.ongoing(),
    );
  }
}
