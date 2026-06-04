import 'package:tictactoe/core/async/serial_task_queue.dart';
import 'package:tictactoe/core/audio/domain/entities/audio_preferences.dart';
import 'package:tictactoe/core/audio/domain/repositories/audio_preferences_repository.dart';
import 'package:tictactoe/core/logging/app_logger.dart';
import 'package:tictactoe/core/storage/json_key_value_store.dart';
import 'package:tictactoe/core/storage/key_value_storage.dart';

final class LocalAudioPreferencesRepository
    implements AudioPreferencesRepository {
  LocalAudioPreferencesRepository(KeyValueStorage storage)
    : _jsonStore = JsonKeyValueStore(storage);

  static const _audioPreferencesKey = 'audio_preferences';
  static const _legacyAudioPreferencesKey = 'eldenAudioPreferences';

  final JsonKeyValueStore _jsonStore;
  final _pendingWrite = SerialTaskQueue();

  @override
  Future<AudioPreferences> load() async {
    final json =
        await _jsonStore.readObject(
          _audioPreferencesKey,
          AudioPreferences.fromJson,
        ) ??
        await _jsonStore.readObject(
          _legacyAudioPreferencesKey,
          AudioPreferences.fromJson,
        );

    return json ?? const AudioPreferences();
  }

  @override
  Future<void> save(AudioPreferences settings) {
    return _pendingWrite.enqueue(() => _writeSettings(settings));
  }

  Future<void> _writeSettings(AudioPreferences settings) async {
    try {
      await _jsonStore.writeObject(_audioPreferencesKey, settings.toJson());
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Audio preferences could not be persisted.',
        name: 'tictactoe.audio.preferences',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
