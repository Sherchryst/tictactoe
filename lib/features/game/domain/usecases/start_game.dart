import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';

final class StartGame {
  const StartGame();

  GameSession call(GameSetup setup) {
    return GameSession.newGame(setup);
  }
}
