import '../entities/game_settings.dart';

abstract interface class GameSettingsRepository {
  Future<GameSettings> load();

  Future<void> save(GameSettings settings);
}
