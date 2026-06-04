import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/game_rules.dart';

final class PlayMove {
  const PlayMove({GameRules rules = const GameRules()}) : _rules = rules;

  final GameRules _rules;

  GameSession call(GameSession session, Mark mark, int cellIndex) {
    if (!session.result.isOngoing ||
        mark != session.currentMark ||
        !session.board.canPlace(cellIndex)) {
      return session;
    }

    final board = session.board.place(mark, cellIndex);
    final result = _rules.evaluate(board);

    return session.copyWith(
      board: board,
      currentMark: result is GameOngoing ? mark.opponent : mark,
      result: result,
    );
  }
}
