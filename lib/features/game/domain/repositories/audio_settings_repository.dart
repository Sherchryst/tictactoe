import 'package:tictactoe/features/game/domain/entities/game_audio_settings.dart';

abstract interface class AudioSettingsRepository {
  Future<GameAudioSettings> load();

  Future<void> save(GameAudioSettings settings);
}
