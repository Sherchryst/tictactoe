import 'package:tictactoe/features/game/domain/entities/game_session.dart';

abstract interface class NoMercyRunRepository {
  Future<GameSession?> load();

  Future<void> save(GameSession session);

  Future<void> clear();
}
