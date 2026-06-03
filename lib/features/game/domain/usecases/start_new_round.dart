import 'package:tictactoe/features/game/domain/entities/game_session.dart';

final class StartNewRound {
  const StartNewRound();

  GameSession call(GameSession session) {
    return session.startNewRound();
  }
}
