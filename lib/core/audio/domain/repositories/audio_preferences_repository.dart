import 'package:tictactoe/core/audio/domain/entities/audio_preferences.dart';

abstract interface class AudioPreferencesRepository {
  Future<AudioPreferences> load();

  Future<void> save(AudioPreferences settings);
}
