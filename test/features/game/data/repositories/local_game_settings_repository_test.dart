import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/data/datasources/local_game_preferences_data_source.dart';
import 'package:tictactoe/features/game/data/repositories/local_game_settings_repository.dart';
import 'package:tictactoe/features/game/domain/entities/app_theme_preference.dart';
import 'package:tictactoe/features/game/domain/entities/game_difficulty.dart';
import 'package:tictactoe/features/game/domain/entities/game_mode.dart';
import 'package:tictactoe/features/game/domain/entities/game_settings.dart';

import '../../../../helpers/fake_key_value_storage.dart';

void main() {
  late FakeKeyValueStorage storage;
  late LocalGameSettingsRepository repository;

  setUp(() {
    storage = FakeKeyValueStorage();
    repository = LocalGameSettingsRepository(
      LocalGamePreferencesDataSource(storage),
    );
  });

  test('returns default settings when none are saved', () async {
    expect(await repository.load(), GameSettings.defaults());
  });

  test('saves and loads settings', () async {
    const settings = GameSettings(
      mode: GameMode.humanVsHuman,
      difficulty: GameDifficulty.hard,
      themePreference: AppThemePreference.light,
    );

    await repository.save(settings);

    expect(await repository.load(), settings);
  });
}
