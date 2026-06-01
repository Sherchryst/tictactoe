import '../entities/game_settings.dart';
import '../repositories/game_settings_repository.dart';

final class LoadGameSettings {
  const LoadGameSettings(this._repository);

  final GameSettingsRepository _repository;

  Future<GameSettings> call() {
    return _repository.load();
  }
}
