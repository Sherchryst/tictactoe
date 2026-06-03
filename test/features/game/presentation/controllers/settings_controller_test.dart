import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/app/di/game_dependencies.dart';
import 'package:tictactoe/core/storage/in_memory_key_value_storage.dart';
import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';
import 'package:tictactoe/features/game/presentation/settings/controllers/settings_controller.dart';

import 'package:tictactoe/testing/provider_container_factory.dart';

void main() {
  ProviderContainer createContainer(InMemoryKeyValueStorage storage) {
    return createTestContainer(
      registerTearDown: addTearDown,
      overrides: [keyValueStorageProvider.overrideWithValue(storage)],
    );
  }

  test('loads default preferences and scoreboard', () async {
    final container = createContainer(InMemoryKeyValueStorage());

    final state = await container.read(settingsControllerProvider.future);

    expect(state.preferences, AppPreferences.defaults());
    expect(state.scoreboard, Scoreboard.empty());
  });

  test('updates and persists locale preference', () async {
    final storage = InMemoryKeyValueStorage();
    final container = createContainer(storage);
    await container.read(settingsControllerProvider.future);

    await container
        .read(settingsControllerProvider.notifier)
        .setLocalePreference(AppLocalePreference.german);

    final reloadedContainer = createContainer(storage);
    final reloadedState = await reloadedContainer.read(
      settingsControllerProvider.future,
    );

    expect(
      reloadedState.preferences.localePreference,
      AppLocalePreference.german,
    );
  });
}
