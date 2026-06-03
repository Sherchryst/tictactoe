import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/data/services/audio_asset_cache.dart';

class _RecordingBundle extends CachingAssetBundle {
  _RecordingBundle({required this.bytes});

  final Uint8List bytes;
  int loadCalls = 0;

  @override
  Future<ByteData> load(String key) async {
    loadCalls += 1;
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '';
  }
}

class _MissingBundle extends CachingAssetBundle {
  int loadCalls = 0;

  @override
  Future<ByteData> load(String key) async {
    loadCalls += 1;
    throw FlutterError('missing asset');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '';
  }
}

void main() {
  group('AudioAssetCache', () {
    test('returns true for assets present in the bundle', () async {
      final bundle = _RecordingBundle(bytes: Uint8List.fromList([1, 2, 3, 4]));
      final cache = AudioAssetCache(bundle: bundle);

      expect(await cache.exists('asset.mp3'), isTrue);
    });

    test('returns false when the asset is missing', () async {
      final bundle = _MissingBundle();
      final cache = AudioAssetCache(bundle: bundle);

      expect(await cache.exists('asset.mp3'), isFalse);
    });

    test('caches the lookup result', () async {
      final bundle = _RecordingBundle(bytes: Uint8List.fromList([7]));
      final cache = AudioAssetCache(bundle: bundle);

      await cache.exists('asset.mp3');
      await cache.exists('asset.mp3');

      expect(bundle.loadCalls, 1);
    });

    test('caches missing assets too', () async {
      final bundle = _MissingBundle();
      final cache = AudioAssetCache(bundle: bundle);

      await cache.exists('asset.mp3');
      await cache.exists('asset.mp3');

      expect(bundle.loadCalls, 1);
    });
  });
}
