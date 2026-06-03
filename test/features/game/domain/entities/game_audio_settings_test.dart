import 'package:flutter_test/flutter_test.dart';

import 'package:tictactoe/features/game/domain/entities/game_audio_settings.dart';

void main() {
  group('GameAudioSettings', () {
    test('uses 50 percent music and 80 percent sfx by default', () {
      const state = GameAudioSettings();

      expect(state.musicVolume, 0.5);
      expect(state.sfxVolume, 0.8);
      expect(state.effectiveMusicVolume, closeTo(0.2, 0.0001));
      expect(state.effectiveSfxVolume(), 0.3);
      expect(state.defaultsVersion, GameAudioSettings.currentDefaultsVersion);
    });

    test('migrates the previous untouched default volumes', () {
      final state = GameAudioSettings.fromJson({
        'musicEnabled': true,
        'sfxEnabled': true,
        'musicVolume': 0.42,
        'sfxVolume': 0.85,
      });

      expect(state.musicVolume, 0.5);
      expect(state.sfxVolume, 0.8);
      expect(state.defaultsVersion, GameAudioSettings.currentDefaultsVersion);
    });

    test('preserves explicit custom volumes from old preferences', () {
      final state = GameAudioSettings.fromJson({
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
        GameAudioSettings.effectiveOutputVolume(0.25),
        closeTo(0.1, 0.0001),
      );
      expect(
        GameAudioSettings.effectiveOutputVolume(0.5),
        closeTo(0.2, 0.0001),
      );
    });

    test('never exceeds 30 percent true output volume', () {
      expect(GameAudioSettings.effectiveOutputVolume(1), 0.3);
      expect(
        GameAudioSettings.effectiveOutputVolume(1, volumeMultiplier: 2),
        0.3,
      );
    });
  });
}
