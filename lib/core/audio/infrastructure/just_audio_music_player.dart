import 'dart:async';
import 'dart:math' as math;

import 'package:just_audio/just_audio.dart' as just_audio;

import 'package:tictactoe/core/audio/domain/entities/audio_preferences.dart';
import 'package:tictactoe/core/audio/infrastructure/audio_session_configurator.dart';
import 'package:tictactoe/core/audio/infrastructure/music_player.dart';
import 'package:tictactoe/core/logging/app_logger.dart';

final class JustAudioMusicPlayer implements MusicPlayer {
  JustAudioMusicPlayer({
    required AudioSessionConfigurator sessionConfigurator,
    just_audio.AudioPlayer? player,
    Duration fadeFrame = const Duration(milliseconds: 45),
  }) : _sessionConfigurator = sessionConfigurator,
       _player = player ?? just_audio.AudioPlayer(),
       _fadeFrame = fadeFrame;

  final AudioSessionConfigurator _sessionConfigurator;
  final just_audio.AudioPlayer _player;
  final Duration _fadeFrame;

  var _transitionId = 0;
  String? _loadingAsset;
  String? _currentAsset;
  var _disposed = false;

  @override
  Future<void> play(
    String asset, {
    required double targetVolume,
    Duration transitionDuration = const Duration(milliseconds: 420),
    Duration startAt = Duration.zero,
  }) async {
    if (_disposed || _loadingAsset == asset) {
      return;
    }

    final transitionId = ++_transitionId;
    _loadingAsset = asset;
    try {
      await _sessionConfigurator.configure();
      if (!_isActiveTransition(transitionId)) {
        return;
      }

      if (_currentAsset == asset) {
        if (_player.playing) {
          await _setVolume(targetVolume);
          return;
        }

        await _setVolume(0);
        if (!_isActiveTransition(transitionId)) {
          return;
        }

        unawaited(
          _player.play().onError((error, stackTrace) {
            _logError('Music playback failed.', error, stackTrace);
          }),
        );
        await _fade(
          to: targetVolume,
          duration: transitionDuration.inMilliseconds,
          transitionId: transitionId,
        );
        return;
      }

      final shouldFadeOut = _player.playing && _currentAsset != null;
      final fadeOutDuration = shouldFadeOut
          ? transitionDuration.inMilliseconds ~/ 2
          : 0;
      final fadeInDuration =
          transitionDuration.inMilliseconds - fadeOutDuration;

      if (shouldFadeOut) {
        final faded = await _fade(
          to: 0,
          duration: fadeOutDuration,
          transitionId: transitionId,
        );
        if (!faded) {
          return;
        }
        await _player.stop();
      }

      if (!_isActiveTransition(transitionId)) {
        return;
      }

      await _player.setLoopMode(just_audio.LoopMode.one);
      await _player.setAsset(asset);
      if (!_isActiveTransition(transitionId)) {
        return;
      }

      if (startAt > Duration.zero) {
        await _player.seek(startAt);
      }
      if (!_isActiveTransition(transitionId)) {
        return;
      }

      _currentAsset = asset;
      await _setVolume(0);
      unawaited(
        _player.play().onError((error, stackTrace) {
          _logError('Music playback failed.', error, stackTrace);
        }),
      );
      await _fade(
        to: targetVolume,
        duration: fadeInDuration,
        transitionId: transitionId,
      );
    } catch (error, stackTrace) {
      _logError('Music track could not be started: $asset', error, stackTrace);
    } finally {
      if (_loadingAsset == asset) {
        _loadingAsset = null;
      }
    }
  }

  @override
  Future<void> prepare(String asset) async {
    if (_disposed || _loadingAsset == asset || _currentAsset == asset) {
      return;
    }

    if (_player.playing) {
      return;
    }

    final transitionId = ++_transitionId;
    _loadingAsset = asset;
    try {
      await _sessionConfigurator.configure();
      if (!_isActiveTransition(transitionId)) {
        return;
      }

      await _player.setLoopMode(just_audio.LoopMode.one);
      await _player.setAsset(asset);
      if (!_isActiveTransition(transitionId)) {
        return;
      }

      _currentAsset = asset;
      await _setVolume(0);
      if (_player.playing) {
        await _player.pause();
      }
    } catch (error, stackTrace) {
      _logError('Music track could not be prepared: $asset', error, stackTrace);
    } finally {
      if (_loadingAsset == asset) {
        _loadingAsset = null;
      }
    }
  }

  @override
  Future<void> pause({
    Duration fadeDuration = const Duration(milliseconds: 450),
  }) async {
    final transitionId = ++_transitionId;
    try {
      final faded = await _fade(
        to: 0,
        duration: fadeDuration.inMilliseconds,
        transitionId: transitionId,
      );
      if (!faded) {
        return;
      }

      await _player.pause();
    } catch (error, stackTrace) {
      _logError('Music playback could not be paused.', error, stackTrace);
    }
  }

  @override
  Future<void> stop({
    Duration fadeDuration = const Duration(milliseconds: 450),
  }) async {
    final transitionId = ++_transitionId;
    try {
      final faded = await _fade(
        to: 0,
        duration: fadeDuration.inMilliseconds,
        transitionId: transitionId,
      );
      if (!faded) {
        return;
      }

      await _player.stop();
      _currentAsset = null;
    } catch (error, stackTrace) {
      _logError('Music playback could not be stopped.', error, stackTrace);
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      await _setVolume(volume);
    } catch (error, stackTrace) {
      _logError('Music volume could not be changed.', error, stackTrace);
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    try {
      await _player.dispose();
    } catch (error, stackTrace) {
      _logError('Music player could not be disposed.', error, stackTrace);
    }
  }

  Future<void> _setVolume(double volume) {
    return _player.setVolume(AudioPreferences.effectiveOutputVolume(volume));
  }

  bool _isActiveTransition(int transitionId) {
    return !_disposed && transitionId == _transitionId;
  }

  void _logError(String message, Object? error, StackTrace stackTrace) {
    AppLogger.warning(
      message,
      name: 'tictactoe.audio.music',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<bool> _fade({
    required double to,
    required int duration,
    required int transitionId,
  }) async {
    final from = _player.volume;
    final target = AudioPreferences.effectiveOutputVolume(to);
    final steps = math.max(1, duration ~/ _fadeFrame.inMilliseconds);

    for (var index = 1; index <= steps; index++) {
      if (!_isActiveTransition(transitionId)) {
        return false;
      }

      final progress = index / steps;
      final volume = from + (target - from) * progress;
      await _player.setVolume(
        volume.clamp(0, AudioPreferences.maxOutputVolume).toDouble(),
      );
      await Future<void>.delayed(_fadeFrame);
    }

    return _isActiveTransition(transitionId);
  }
}
