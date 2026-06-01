import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/di/game_dependencies.dart';
import 'package:tictactoe/features/game/domain/entities/app_theme_preference.dart';
import 'package:tictactoe/features/game/domain/entities/game_difficulty.dart';
import 'package:tictactoe/features/game/domain/entities/game_mode.dart';
import 'package:tictactoe/features/game/domain/entities/game_settings.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';
import 'package:tictactoe/features/settings/presentation/controllers/settings_controller.dart';

import '../../../../helpers/fake_key_value_storage.dart';

void main() {
  ProviderContainer createContainer(FakeKeyValueStorage storage) {
    final container = ProviderContainer(
      overrides: [keyValueStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('loads default settings and scoreboard', () async {
    final container = createContainer(FakeKeyValueStorage());

    final state = await container.read(settingsControllerProvider.future);

    expect(state.settings, GameSettings.defaults());
    expect(state.scoreboard, Scoreboard.empty());
  });

  test('updates and persists difficulty', () async {
    final storage = FakeKeyValueStorage();
    final container = createContainer(storage);
    await container.read(settingsControllerProvider.future);

    await container
        .read(settingsControllerProvider.notifier)
        .setDifficulty(GameDifficulty.hard);

    final reloadedContainer = createContainer(storage);
    final reloadedState = await reloadedContainer.read(
      settingsControllerProvider.future,
    );

    expect(reloadedState.settings.difficulty, GameDifficulty.hard);
  });

  test('updates and persists mode', () async {
    final storage = FakeKeyValueStorage();
    final container = createContainer(storage);
    await container.read(settingsControllerProvider.future);

    await container
        .read(settingsControllerProvider.notifier)
        .setMode(GameMode.humanVsHuman);

    final reloadedContainer = createContainer(storage);
    final reloadedState = await reloadedContainer.read(
      settingsControllerProvider.future,
    );

    expect(reloadedState.settings.mode, GameMode.humanVsHuman);
  });

  test('updates and persists theme preference', () async {
    final storage = FakeKeyValueStorage();
    final container = createContainer(storage);
    await container.read(settingsControllerProvider.future);

    await container
        .read(settingsControllerProvider.notifier)
        .setThemePreference(AppThemePreference.dark);

    final state = container.read(settingsControllerProvider).requireValue;

    expect(state.settings.themePreference, AppThemePreference.dark);
  });
}
