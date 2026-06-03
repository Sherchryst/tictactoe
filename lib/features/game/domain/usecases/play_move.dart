import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/game_rules.dart';

final class PlayMove {
  const PlayMove({GameRules rules = const GameRules()}) : _rules = rules;

  final GameRules _rules;

  GameSession call(GameSession session, Player player, int cellIndex) {
    if (!session.result.isOngoing ||
        player != session.currentPlayer ||
        !session.board.canPlace(cellIndex)) {
      return session;
    }

    final board = session.board.place(player.cell, cellIndex);
    final result = _rules.evaluate(board);

    return session.copyWith(
      board: board,
      currentPlayer: result is GameOngoing ? player.opponent : player,
      result: result,
    );
  }
}
