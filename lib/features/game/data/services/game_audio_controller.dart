import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tictactoe/core/assets/app_assets.dart';
import 'package:tictactoe/core/storage/storage_providers.dart';
import 'package:tictactoe/features/game/data/repositories/local_audio_settings_repository.dart';
import 'package:tictactoe/features/game/data/services/audio_asset_cache.dart';
import 'package:tictactoe/features/game/data/services/audio_session_configurator.dart';
import 'package:tictactoe/features/game/data/services/just_audio_music_player.dart';
import 'package:tictactoe/features/game/data/services/just_audio_sfx_player.dart';
import 'package:tictactoe/features/game/domain/entities/game_audio_settings.dart';
import 'package:tictactoe/features/game/domain/entities/menu_sfx.dart';
import 'package:tictactoe/features/game/domain/entities/music_track.dart';
import 'package:tictactoe/features/game/domain/repositories/audio_settings_repository.dart';
import 'package:tictactoe/features/game/domain/services/audio_controller.dart';
import 'package:tictactoe/features/game/domain/services/music_player.dart';
import 'package:tictactoe/features/game/domain/services/sfx_player.dart';

part 'game_audio_controller.g.dart';

@Riverpod(keepAlive: true)
AudioSettingsRepository localAudioSettingsRepository(Ref ref) {
  return LocalAudioSettingsRepository(ref.watch(keyValueStorageProvider));
}

@Riverpod(keepAlive: true)
MusicPlayer musicPlayer(Ref ref) {
  return JustAudioMusicPlayer(sessionConfigurator: AudioSessionConfigurator());
}

@Riverpod(keepAlive: true)
SfxPlayer sfxPlayer(Ref ref) {
  return JustAudioSfxPlayer(assetCache: AudioAssetCache());
}

@Riverpod(keepAlive: true)
final class GameAudioController extends _$GameAudioController
    implements AudioController {
  static const _menuTransition = Duration(milliseconds: 420);
  static const _gameTransition = Duration(seconds: 5);

  static const _trackAssets = <MusicTrack, String>{
    MusicTrack.menu: AppAssets.musicLoop,
    MusicTrack.game: AppAssets.gameMusic,
  };

  static const _trackTransitions = <MusicTrack, Duration>{
    MusicTrack.menu: _menuTransition,
    MusicTrack.game: _gameTransition,
  };

  static const _menuSfxAssets = <MenuSfx, _SfxBinding>{
    MenuSfx.select: _SfxBinding(AppAssets.selection, 0.78),
    MenuSfx.activate: _SfxBinding(AppAssets.titleStart, 0.86),
    MenuSfx.reset: _SfxBinding(AppAssets.restartGrace, 0.86),
  };

  static const _warmUpAssets = <String>[
    AppAssets.titleStart,
    AppAssets.selection,
    AppAssets.parry,
    AppAssets.victory,
    AppAssets.deathIntro,
    AppAssets.death,
    AppAssets.criticalHit,
    AppAssets.restartGrace,
  ];

  late final AudioSettingsRepository _repository;
  late final MusicPlayer _musicPlayer;
  late final SfxPlayer _sfxPlayer;
  MusicTrack? _pendingTrack;
  var _settingsLoaded = false;
  var _disposed = false;

  @override
  GameAudioSettings build() {
    _repository = ref.read(localAudioSettingsRepositoryProvider);
    _musicPlayer = ref.read(musicPlayerProvider);
    _sfxPlayer = ref.read(sfxPlayerProvider);

    ref.onDispose(_dispose);
    unawaited(_initialize());

    return const GameAudioSettings();
  }

  @override
  Future<void> playTrack(MusicTrack track) {
    if (_disposed) {
      return Future<void>.value();
    }

    if (!_settingsLoaded) {
      _pendingTrack = track;
      return Future<void>.value();
    }

    if (!state.musicEnabled) {
      return Future<void>.value();
    }

    return _playTrackNow(track);
  }

  Future<void> _playTrackNow(MusicTrack track) {
    return _musicPlayer.play(
      _trackAssets[track]!,
      targetVolume: state.musicVolume,
      transitionDuration: _trackTransitions[track]!,
    );
  }

  @override
  Future<void> prepareGame() {
    if (_disposed) {
      return Future<void>.value();
    }

    return _musicPlayer.prepare(_trackAssets[MusicTrack.game]!);
  }

  @override
  Future<void> pauseMusic() => _musicPlayer.pause();

  @override
  Future<void> stopMusic() => _musicPlayer.stop();

  @override
  Future<void> playMenuSfx(MenuSfx intent) {
    final binding = _menuSfxAssets[intent]!;
    return _playSfx(binding.asset, volumeMultiplier: binding.volumeMultiplier);
  }

  @override
  Future<void> playMove({required bool isPlayerX}) {
    return _playSfx(AppAssets.selection, volumeMultiplier: 0.46);
  }

  @override
  Future<void> playParry() {
    return _playSfx(AppAssets.parry, volumeMultiplier: 0.74);
  }

  @override
  Future<void> playVictory() {
    return _playSfx(AppAssets.victory, volumeMultiplier: 0.9);
  }

  @override
  Future<void> playDeathIntro() {
    return _playSfx(AppAssets.deathIntro, volumeMultiplier: 0.86);
  }

  @override
  Future<void> playDeath() {
    return _playSfx(AppAssets.death, volumeMultiplier: 0.92);
  }

  @override
  Future<void> playDraw() {
    return _playSfx(AppAssets.criticalHit, volumeMultiplier: 0.86);
  }

  @override
  Future<void> playRestart() => playMenuSfx(MenuSfx.reset);

  @override
  void setMusicEnabled(bool enabled) {
    state = state.copyWith(musicEnabled: enabled);
    unawaited(_repository.save(state));
    unawaited(enabled ? playTrack(MusicTrack.menu) : pauseMusic());
  }

  @override
  void setSfxEnabled(bool enabled) {
    state = state.copyWith(sfxEnabled: enabled);
    unawaited(_repository.save(state));
  }

  @override
  void setMusicVolume(double volume) {
    state = state.copyWith(musicVolume: volume.clamp(0, 1).toDouble());
    unawaited(_repository.save(state));
    unawaited(_musicPlayer.setVolume(state.musicVolume));
  }

  @override
  void setSfxVolume(double volume) {
    state = state.copyWith(sfxVolume: volume.clamp(0, 1).toDouble());
    unawaited(_repository.save(state));
  }

  Future<void> _initialize() async {
    state = await _repository.load();
    if (_disposed) {
      return;
    }

    _settingsLoaded = true;
    unawaited(_sfxPlayer.warmUp(_warmUpAssets));
    if (state.musicEnabled) {
      final track = _pendingTrack ?? MusicTrack.menu;
      _pendingTrack = null;
      unawaited(_playTrackNow(track));
    } else {
      _pendingTrack = null;
      unawaited(pauseMusic());
    }
  }

  Future<void> _playSfx(String asset, {required double volumeMultiplier}) {
    if (_disposed || !state.sfxEnabled) {
      return Future<void>.value();
    }

    return _sfxPlayer.play(
      asset,
      volume: state.effectiveSfxVolume(volumeMultiplier: volumeMultiplier),
    );
  }

  void _dispose() {
    _disposed = true;
    unawaited(_musicPlayer.dispose());
    unawaited(_sfxPlayer.dispose());
  }
}

final class _SfxBinding {
  const _SfxBinding(this.asset, this.volumeMultiplier);

  final String asset;
  final double volumeMultiplier;
}
