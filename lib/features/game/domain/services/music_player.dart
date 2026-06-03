abstract interface class MusicPlayer {
  Future<void> play(
    String asset, {
    required double targetVolume,
    Duration transitionDuration,
  });

  Future<void> prepare(String asset);

  Future<void> pause({Duration fadeDuration});

  Future<void> stop({Duration fadeDuration});

  Future<void> setVolume(double volume);

  Future<void> dispose();
}
