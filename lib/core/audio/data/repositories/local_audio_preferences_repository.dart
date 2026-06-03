import 'dart:async';
import 'dart:convert';

import 'package:tictactoe/core/audio/domain/entities/audio_preferences.dart';
import 'package:tictactoe/core/audio/domain/repositories/audio_preferences_repository.dart';
import 'package:tictactoe/core/storage/key_value_storage.dart';

final class LocalAudioPreferencesRepository
    implements AudioPreferencesRepository {
  LocalAudioPreferencesRepository(this._storage);

  static const _audioPreferencesKey = 'audio_preferences';
  static const _legacyAudioPreferencesKey = 'eldenAudioPreferences';

  final KeyValueStorage _storage;
  Future<void> _pendingWrite = Future<void>.value();

  @override
  Future<AudioPreferences> load() async {
    final json =
        await _readJson(_audioPreferencesKey) ??
        await _readJson(_legacyAudioPreferencesKey);
    if (json == null) {
      return const AudioPreferences();
    }

    return AudioPreferences.fromJson(json);
  }

  @override
  Future<void> save(AudioPreferences settings) {
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

  Future<void> _writeSettings(AudioPreferences settings) async {
    try {
      await _storage.writeString(
        _audioPreferencesKey,
        jsonEncode(settings.toJson()),
      );
    } catch (_) {}
  }
}
