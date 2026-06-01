import '../entities/game_session.dart';
import '../entities/game_settings.dart';

final class StartGame {
  const StartGame();

  GameSession call(GameSettings settings) {
    return GameSession.newGame(settings);
  }
}
