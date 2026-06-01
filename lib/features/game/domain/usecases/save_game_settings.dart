import '../entities/game_settings.dart';
import '../repositories/game_settings_repository.dart';

final class SaveGameSettings {
  const SaveGameSettings(this._repository);

  final GameSettingsRepository _repository;

  Future<void> call(GameSettings settings) {
    return _repository.save(settings);
  }
}
