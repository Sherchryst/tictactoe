import 'dart:convert';

import '../../../../core/storage/key_value_storage.dart';
import '../models/game_settings_dto.dart';
import '../models/scoreboard_dto.dart';
import 'game_storage_keys.dart';

final class LocalGamePreferencesDataSource {
  const LocalGamePreferencesDataSource(this._storage);

  final KeyValueStorage _storage;

  Future<GameSettingsDto?> loadSettings() async {
    final json = await _storage.readString(GameStorageKeys.settings);
    if (json == null) {
      return null;
    }

    return GameSettingsDto.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveSettings(GameSettingsDto settings) {
    return _storage.writeString(
      GameStorageKeys.settings,
      jsonEncode(settings.toJson()),
    );
  }

  Future<ScoreboardDto?> loadScoreboard() async {
    final json = await _storage.readString(GameStorageKeys.scoreboard);
    if (json == null) {
      return null;
    }

    return ScoreboardDto.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveScoreboard(ScoreboardDto scoreboard) {
    return _storage.writeString(
      GameStorageKeys.scoreboard,
      jsonEncode(scoreboard.toJson()),
    );
  }

  Future<void> resetScoreboard() {
    return _storage.remove(GameStorageKeys.scoreboard);
  }
}
