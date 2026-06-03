abstract interface class SfxPlayer {
  Future<void> play(String asset, {required double volume});

  Future<void> warmUp(Iterable<String> assets);

  Future<void> dispose();
}
