import 'dart:async';
import 'dart:convert';

import 'package:tictactoe/core/storage/key_value_storage.dart';
import 'package:tictactoe/features/game/data/datasources/game_storage_keys.dart';
import 'package:tictactoe/features/game/domain/entities/game_audio_settings.dart';
import 'package:tictactoe/features/game/domain/repositories/audio_settings_repository.dart';

final class LocalAudioSettingsRepository implements AudioSettingsRepository {
  LocalAudioSettingsRepository(this._storage);

  final KeyValueStorage _storage;
  Future<void> _pendingWrite = Future<void>.value();

  @override
  Future<GameAudioSettings> load() async {
    final json =
        await _readJson(GameStorageKeys.audioPreferences) ??
        await _readJson(GameStorageKeys.legacyAudioPreferences);
    if (json == null) {
      return const GameAudioSettings();
    }

    return GameAudioSettings.fromJson(json);
  }

  @override
  Future<void> save(GameAudioSettings settings) {
    final next = _pendingWrite.then((_) => _writeSettings(settings));
    _pendingWrite = next.catchError((_) {});
    return next;
  }

  Future<Map<String, Object?>?> _readJson(String key) async {
    try {
      final raw = await _storage.readString(key);
      if (raw == null) {
        return null;
      }

      final value = jsonDecode(raw);
      return value is Map<String, Object?> ? value : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeSettings(GameAudioSettings settings) async {
    try {
      await _storage.writeString(
        GameStorageKeys.audioPreferences,
        jsonEncode(settings.toJson()),
      );
    } catch (_) {}
  }
}
