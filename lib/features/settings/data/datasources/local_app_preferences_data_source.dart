import 'dart:convert';

import 'package:tictactoe/core/storage/key_value_storage.dart';
import 'package:tictactoe/features/settings/data/models/app_preferences_dto.dart';

final class LocalAppPreferencesDataSource {
  const LocalAppPreferencesDataSource(this._storage);

  static const _preferencesKey = 'app_preferences';

  final KeyValueStorage _storage;

  Future<AppPreferencesDto?> loadPreferences() async {
    final json = await _storage.readString(_preferencesKey);
    if (json == null) {
      return null;
    }

    return _decodeObject(json, AppPreferencesDto.fromJson);
  }

  Future<void> savePreferences(AppPreferencesDto preferences) {
    return _storage.writeString(
      _preferencesKey,
      jsonEncode(preferences.toJson()),
    );
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
