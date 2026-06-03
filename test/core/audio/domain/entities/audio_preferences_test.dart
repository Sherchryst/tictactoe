import 'package:flutter_test/flutter_test.dart';

import 'package:tictactoe/core/audio/domain/entities/audio_preferences.dart';

void main() {
  group('AudioPreferences', () {
    test('uses 50 percent music and 80 percent sfx by default', () {
      const state = AudioPreferences();

      expect(state.musicVolume, 0.5);
      expect(state.sfxVolume, 0.8);
      expect(state.effectiveMusicVolume, closeTo(0.2, 0.0001));
      expect(state.effectiveSfxVolume(), 0.3);
      expect(state.defaultsVersion, AudioPreferences.currentDefaultsVersion);
    });

    test('migrates the previous untouched default volumes', () {
      final state = AudioPreferences.fromJson({
        'musicEnabled': true,
        'sfxEnabled': true,
        'musicVolume': 0.42,
        'sfxVolume': 0.85,
      });

      expect(state.musicVolume, 0.5);
      expect(state.sfxVolume, 0.8);
      expect(state.defaultsVersion, AudioPreferences.currentDefaultsVersion);
    });

    test('preserves explicit custom volumes from old preferences', () {
      final state = AudioPreferences.fromJson({
        'musicEnabled': true,
        'sfxEnabled': true,
        'musicVolume': 0.2,
        'sfxVolume': 0.7,
      });

      expect(state.musicVolume, 0.2);
      expect(state.sfxVolume, 0.7);
    });

    test('maps slider volume to 40 percent of true volume', () {
      expect(
        AudioPreferences.effectiveOutputVolume(0.25),
        closeTo(0.1, 0.0001),
      );
      expect(AudioPreferences.effectiveOutputVolume(0.5), closeTo(0.2, 0.0001));
    });

    test('never exceeds 30 percent true output volume', () {
      expect(AudioPreferences.effectiveOutputVolume(1), 0.3);
      expect(
        AudioPreferences.effectiveOutputVolume(1, volumeMultiplier: 2),
        0.3,
      );
    });
  });
}
