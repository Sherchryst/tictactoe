import 'dart:convert';

import 'package:tictactoe/core/storage/key_value_storage.dart';
import 'package:tictactoe/features/game/data/datasources/game_storage_keys.dart';
import 'package:tictactoe/features/game/data/models/app_preferences_dto.dart';
import 'package:tictactoe/features/game/data/models/scoreboard_dto.dart';

final class LocalGamePreferencesDataSource {
  const LocalGamePreferencesDataSource(this._storage);

  final KeyValueStorage _storage;

  Future<AppPreferencesDto?> loadPreferences() async {
    final json = await _storage.readString(GameStorageKeys.preferences);
    if (json == null) {
      return null;
    }

    return _decodeObject(json, AppPreferencesDto.fromJson);
  }

  Future<void> savePreferences(AppPreferencesDto preferences) {
    return _storage.writeString(
      GameStorageKeys.preferences,
      jsonEncode(preferences.toJson()),
    );
  }

  Future<ScoreboardDto?> loadScoreboard() async {
    final json = await _storage.readString(GameStorageKeys.scoreboard);
    if (json == null) {
      return null;
    }

    return _decodeObject(json, ScoreboardDto.fromJson);
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

  T? _decodeObject<T>(String raw, T Function(Map<String, dynamic>) fromJson) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
