import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/storage/in_memory_key_value_storage.dart';
import 'package:tictactoe/features/game/data/datasources/game_storage_keys.dart';
import 'package:tictactoe/features/game/data/repositories/local_audio_settings_repository.dart';
import 'package:tictactoe/features/game/domain/entities/game_audio_settings.dart';

void main() {
  late InMemoryKeyValueStorage storage;
  late LocalAudioSettingsRepository repository;

  setUp(() {
    storage = InMemoryKeyValueStorage();
    repository = LocalAudioSettingsRepository(storage);
  });

  test('returns defaults when no preferences are saved', () async {
    final loaded = await repository.load();

    expect(loaded.musicEnabled, isTrue);
    expect(loaded.sfxEnabled, isTrue);
    expect(loaded.musicVolume, GameAudioSettings.defaultMusicVolume);
    expect(loaded.sfxVolume, GameAudioSettings.defaultSfxVolume);
  });

  test('saves and loads settings', () async {
    const settings = GameAudioSettings(
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
    const first = GameAudioSettings(musicVolume: 0.1);
    const second = GameAudioSettings(musicVolume: 0.4);
    const third = GameAudioSettings(musicVolume: 0.9);

    await Future.wait([
      repository.save(first),
      repository.save(second),
      repository.save(third),
    ]);

    expect((await repository.load()).musicVolume, third.musicVolume);
  });

  test('migrates legacy preferences when present', () async {
    const legacy = GameAudioSettings(musicVolume: 0.7);
    await storage.writeString(
      GameStorageKeys.legacyAudioPreferences,
      jsonEncode(legacy.toJson()),
    );

    final loaded = await repository.load();

    expect(loaded.musicVolume, legacy.musicVolume);
  });
}
