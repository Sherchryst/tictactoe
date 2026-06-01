import '../../domain/entities/game_settings.dart';
import '../../domain/repositories/game_settings_repository.dart';
import '../datasources/local_game_preferences_data_source.dart';
import '../models/game_settings_dto.dart';

final class LocalGameSettingsRepository implements GameSettingsRepository {
  const LocalGameSettingsRepository(this._dataSource);

  final LocalGamePreferencesDataSource _dataSource;

  @override
  Future<GameSettings> load() async {
    final settings = await _dataSource.loadSettings();
    return settings?.toDomain() ?? GameSettings.defaults();
  }

  @override
  Future<void> save(GameSettings settings) {
    return _dataSource.saveSettings(GameSettingsDto.fromDomain(settings));
  }
}
