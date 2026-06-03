final class GameAudioSettings {
  const GameAudioSettings({
    this.musicEnabled = true,
    this.sfxEnabled = true,
    this.musicVolume = defaultMusicVolume,
    this.sfxVolume = defaultSfxVolume,
    this.defaultsVersion = currentDefaultsVersion,
  });

  static const currentDefaultsVersion = 2;
  static const defaultMusicVolume = 0.5;
  static const defaultSfxVolume = 0.8;
  static const trueVolumeScale = 0.4;
  static const maxOutputVolume = 0.3;
  static const _previousDefaultMusicVolume = 0.42;
  static const _previousDefaultSfxVolume = 0.85;

  final bool musicEnabled;
  final bool sfxEnabled;
  final double musicVolume;
  final double sfxVolume;
  final int defaultsVersion;

  double get effectiveMusicVolume => effectiveOutputVolume(musicVolume);

  double effectiveSfxVolume({double volumeMultiplier = 1}) {
    return effectiveOutputVolume(sfxVolume, volumeMultiplier: volumeMultiplier);
  }

  GameAudioSettings copyWith({
    bool? musicEnabled,
    bool? sfxEnabled,
    double? musicVolume,
    double? sfxVolume,
    int? defaultsVersion,
  }) {
    return GameAudioSettings(
      musicEnabled: musicEnabled ?? this.musicEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      defaultsVersion: defaultsVersion ?? this.defaultsVersion,
    );
  }

  Map<String, Object> toJson() {
    return {
      'musicEnabled': musicEnabled,
      'sfxEnabled': sfxEnabled,
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
      'defaultsVersion': defaultsVersion,
    };
  }

  static GameAudioSettings fromJson(Map<String, Object?> json) {
    final defaultsVersion = switch (json['defaultsVersion']) {
      num value => value.toInt(),
      _ => 1,
    };
    final storedMusicVolume = _volumeFromJson(
      json['musicVolume'],
      fallback: defaultMusicVolume,
    );
    final storedSfxVolume = _volumeFromJson(
      json['sfxVolume'],
      fallback: defaultSfxVolume,
    );

    return GameAudioSettings(
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      sfxEnabled: json['sfxEnabled'] as bool? ?? true,
      musicVolume:
          defaultsVersion < currentDefaultsVersion &&
              storedMusicVolume == _previousDefaultMusicVolume
          ? defaultMusicVolume
          : storedMusicVolume,
      sfxVolume:
          defaultsVersion < currentDefaultsVersion &&
              storedSfxVolume == _previousDefaultSfxVolume
          ? defaultSfxVolume
          : storedSfxVolume,
    );
  }

  static double _volumeFromJson(Object? value, {required double fallback}) {
    return switch (value) {
      num() => value.toDouble().clamp(0, 1).toDouble(),
      _ => fallback,
    };
  }

  static double effectiveOutputVolume(
    double userVolume, {
    double volumeMultiplier = 1,
  }) {
    final normalizedVolume = userVolume.clamp(0, 1).toDouble();
    final normalizedMultiplier = volumeMultiplier < 0 ? 0 : volumeMultiplier;

    return (normalizedVolume * trueVolumeScale * normalizedMultiplier)
        .clamp(0, maxOutputVolume)
        .toDouble();
  }
}
