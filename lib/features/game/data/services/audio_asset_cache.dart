import 'package:flutter/services.dart';

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
    } catch (_) {
      _cache[asset] = false;
      return false;
    }
  }
}
