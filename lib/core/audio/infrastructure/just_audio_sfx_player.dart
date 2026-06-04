import 'dart:async';

import 'package:just_audio/just_audio.dart' as just_audio;

import 'package:tictactoe/core/audio/infrastructure/audio_asset_cache.dart';
import 'package:tictactoe/core/audio/infrastructure/sfx_player.dart';
import 'package:tictactoe/core/logging/app_logger.dart';

final class JustAudioSfxPlayer implements SfxPlayer {
  JustAudioSfxPlayer({
    required AudioAssetCache assetCache,
    int poolSize = 4,
    List<just_audio.AudioPlayer>? players,
  }) : _assetCache = assetCache,
       _players =
           players ?? List.generate(poolSize, (_) => just_audio.AudioPlayer());

  final AudioAssetCache _assetCache;
  final List<just_audio.AudioPlayer> _players;
  var _nextPlayer = 0;
  var _disposed = false;

  @override
  Future<void> play(String asset, {required double volume}) async {
    if (_disposed) {
      return;
    }

    if (!await _assetCache.exists(asset)) {
      return;
    }

    final player = _players[_nextPlayer];
    _nextPlayer = (_nextPlayer + 1) % _players.length;

    try {
      await player.stop();
      await player.setVolume(volume);
      await player.setAsset(asset);
      await player.seek(Duration.zero);
      unawaited(
        player.play().onError((error, stackTrace) {
          _logError('SFX playback failed: $asset', error, stackTrace);
        }),
      );
    } catch (error, stackTrace) {
      _logError('SFX could not be started: $asset', error, stackTrace);
    }
  }

  @override
  Future<void> warmUp(Iterable<String> assets) async {
    for (final asset in assets) {
      await _assetCache.exists(asset);
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    for (final player in _players) {
      try {
        await player.dispose();
      } catch (error, stackTrace) {
        _logError('SFX player could not be disposed.', error, stackTrace);
      }
    }
  }

  void _logError(String message, Object? error, StackTrace stackTrace) {
    AppLogger.warning(
      message,
      name: 'tictactoe.audio.sfx',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
