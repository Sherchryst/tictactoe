import 'package:flutter/services.dart';

import 'package:tictactoe/core/logging/app_logger.dart';

final class AudioAssetCache {
  AudioAssetCache({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final _cache = <String, bool>{};

  Future<bool> exists(String asset) async {
    final cached = _cache[asset];
    if (cached != null) {
      return cached;
    }

    try {
      final data = await _bundle.load(asset);
      final exists = data.lengthInBytes > 0;
      _cache[asset] = exists;
      return exists;
    } catch (error, stackTrace) {
      _cache[asset] = false;
      AppLogger.warning(
        'Audio asset could not be loaded: $asset',
        name: 'tictactoe.audio.assets',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
