import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictactoe/core/audio/data/repositories/local_audio_preferences_repository.dart';
import 'package:tictactoe/core/audio/domain/repositories/audio_preferences_repository.dart';
import 'package:tictactoe/core/audio/infrastructure/audio_asset_cache.dart';
import 'package:tictactoe/core/audio/infrastructure/audio_session_configurator.dart';
import 'package:tictactoe/core/audio/infrastructure/just_audio_music_player.dart';
import 'package:tictactoe/core/audio/infrastructure/just_audio_sfx_player.dart';
import 'package:tictactoe/core/audio/infrastructure/music_player.dart';
import 'package:tictactoe/core/audio/infrastructure/sfx_player.dart';
import 'package:tictactoe/core/di/storage_providers.dart';

part 'audio_dependencies.g.dart';

@Riverpod(keepAlive: true)
AudioPreferencesRepository localAudioPreferencesRepository(Ref ref) {
  return LocalAudioPreferencesRepository(ref.watch(keyValueStorageProvider));
}

@Riverpod(keepAlive: true)
MusicPlayer musicPlayer(Ref ref) {
  return JustAudioMusicPlayer(sessionConfigurator: AudioSessionConfigurator());
}

@Riverpod(keepAlive: true)
SfxPlayer sfxPlayer(Ref ref) {
  return JustAudioSfxPlayer(assetCache: AudioAssetCache());
}
