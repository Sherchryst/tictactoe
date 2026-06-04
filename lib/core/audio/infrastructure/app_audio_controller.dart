import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictactoe/core/audio/domain/entities/audio_preferences.dart';
import 'package:tictactoe/core/audio/domain/entities/menu_sfx.dart';
import 'package:tictactoe/core/audio/domain/entities/music_track.dart';
import 'package:tictactoe/core/audio/domain/repositories/audio_preferences_repository.dart';
import 'package:tictactoe/core/audio/domain/services/audio_controller.dart';
import 'package:tictactoe/core/audio/domain/services/audio_preferences_controller.dart';
import 'package:tictactoe/core/audio/infrastructure/audio_asset_catalog.dart';
import 'package:tictactoe/core/audio/infrastructure/music_player.dart';
import 'package:tictactoe/core/audio/infrastructure/sfx_player.dart';
import 'package:tictactoe/core/di/audio_dependencies.dart';

part 'app_audio_controller.g.dart';

@Riverpod(keepAlive: true)
final class AppAudioController extends _$AppAudioController
    implements AudioController, AudioPreferencesController {
  static const _assets = AudioAssetCatalog();

  late final AudioPreferencesRepository _repository;
  late final MusicPlayer _musicPlayer;
  late final SfxPlayer _sfxPlayer;
  MusicTrack? _pendingTrack;
  var _requestedTrack = MusicTrack.menu;
  var _settingsLoaded = false;
  var _disposed = false;

  @override
  AudioPreferences build() {
    _repository = ref.read(localAudioPreferencesRepositoryProvider);
    _musicPlayer = ref.read(musicPlayerProvider);
    _sfxPlayer = ref.read(sfxPlayerProvider);

    ref.onDispose(_dispose);
    unawaited(_initialize());

    return const AudioPreferences();
  }

  @override
  Future<void> playTrack(MusicTrack track) {
    _requestedTrack = track;
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
    final binding = _assets.track(track);
    return _musicPlayer.play(
      binding.asset,
      targetVolume: state.musicVolume,
      transitionDuration: binding.transitionDuration,
      startAt: binding.startAt,
    );
  }

  @override
  Future<void> prepareGame() {
    if (_disposed) {
      return Future<void>.value();
    }

    final track = _requestedTrack == MusicTrack.menu
        ? MusicTrack.recusants
        : _requestedTrack;
    return _musicPlayer.prepare(_assets.track(track).asset);
  }

  @override
  Future<void> pauseMusic() => _musicPlayer.pause();

  @override
  Future<void> resumeMusic() => playTrack(_requestedTrack);

  @override
  Future<void> stopMusic() => _musicPlayer.stop();

  @override
  Future<void> playMenuSfx(MenuSfx intent) {
    final binding = _assets.menuSfx(intent);
    return _playSfx(binding);
  }

  @override
  Future<void> playHumanMark() {
    return _playSfx(AudioAssetCatalog.humanMark);
  }

  @override
  Future<void> playCpuMark() {
    return _playSfx(AudioAssetCatalog.cpuMark);
  }

  @override
  Future<void> playMaleniaVictoryLine() {
    return _playSfx(AudioAssetCatalog.maleniaVictoryLine);
  }

  @override
  Future<void> playParry() {
    return _playSfx(AudioAssetCatalog.parry);
  }

  @override
  Future<void> playVictory() {
    return _playSfx(AudioAssetCatalog.victory);
  }

  @override
  Future<void> playDeathIntro() {
    return _playSfx(AudioAssetCatalog.deathIntro);
  }

  @override
  Future<void> playDeath() {
    return _playSfx(AudioAssetCatalog.death);
  }

  @override
  Future<void> playDraw() {
    return _playSfx(AudioAssetCatalog.draw);
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
    unawaited(_sfxPlayer.warmUp(AudioAssetCatalog.warmUpAssets));
    if (state.musicEnabled) {
      final track = _pendingTrack ?? MusicTrack.menu;
      _pendingTrack = null;
      unawaited(_playTrackNow(track));
    } else {
      _pendingTrack = null;
      unawaited(pauseMusic());
    }
  }

  Future<void> _playSfx(AudioSfxBinding binding) {
    if (_disposed || !state.sfxEnabled) {
      return Future<void>.value();
    }

    return _sfxPlayer.play(
      binding.asset,
      volume: state.effectiveSfxVolume(
        volumeMultiplier: binding.volumeMultiplier,
      ),
    );
  }

  void _dispose() {
    _disposed = true;
    unawaited(_musicPlayer.dispose());
    unawaited(_sfxPlayer.dispose());
  }
}
