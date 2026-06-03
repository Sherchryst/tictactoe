import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/audio/data/repositories/local_audio_preferences_repository.dart';
import 'package:tictactoe/core/audio/domain/entities/audio_preferences.dart';

import '../../../../testing/in_memory_key_value_storage.dart';

void main() {
  late InMemoryKeyValueStorage storage;
  late LocalAudioPreferencesRepository repository;

  setUp(() {
    storage = InMemoryKeyValueStorage();
    repository = LocalAudioPreferencesRepository(storage);
  });

  test('returns defaults when no preferences are saved', () async {
    final loaded = await repository.load();

    expect(loaded.musicEnabled, isTrue);
    expect(loaded.sfxEnabled, isTrue);
    expect(loaded.musicVolume, AudioPreferences.defaultMusicVolume);
    expect(loaded.sfxVolume, AudioPreferences.defaultSfxVolume);
  });

  test('saves and loads settings', () async {
    const settings = AudioPreferences(
      musicEnabled: false,
      sfxEnabled: false,
      musicVolume: 0.2,
      sfxVolume: 0.3,
    );

    await repository.save(settings);

    final loaded = await repository.load();
    expect(loaded.musicEnabled, settings.musicEnabled);
    expect(loaded.sfxEnabled, settings.sfxEnabled);
    expect(loaded.musicVolume, settings.musicVolume);
    expect(loaded.sfxVolume, settings.sfxVolume);
  });

  test('serializes concurrent saves', () async {
    const first = AudioPreferences(musicVolume: 0.1);
    const second = AudioPreferences(musicVolume: 0.4);
    const third = AudioPreferences(musicVolume: 0.9);

    await Future.wait([
      repository.save(first),
      repository.save(second),
      repository.save(third),
    ]);

    expect((await repository.load()).musicVolume, third.musicVolume);
  });

  test('migrates legacy preferences when present', () async {
    const legacy = AudioPreferences(musicVolume: 0.7);
    await storage.writeString(
      'eldenAudioPreferences',
      jsonEncode(legacy.toJson()),
    );

    final loaded = await repository.load();

    expect(loaded.musicVolume, legacy.musicVolume);
  });
}
