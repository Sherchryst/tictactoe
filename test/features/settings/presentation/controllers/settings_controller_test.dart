import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/core/preferences/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/settings/presentation/controllers/settings_controller.dart';

import '../../../../testing/in_memory_key_value_storage.dart';
import '../../../../testing/provider_container_factory.dart';

void main() {
  ProviderContainer createContainer(InMemoryKeyValueStorage storage) {
    return createTestContainer(
      registerTearDown: addTearDown,
      overrides: [keyValueStorageProvider.overrideWithValue(storage)],
    );
  }

  test('loads default preferences', () async {
    final container = createContainer(InMemoryKeyValueStorage());

    final state = await container.read(settingsControllerProvider.future);

    expect(state.preferences, AppPreferences.defaults());
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

  test('updates and persists score reset confirmation preference', () async {
    final storage = InMemoryKeyValueStorage();
    final container = createContainer(storage);
    await container.read(settingsControllerProvider.future);

    await container
        .read(settingsControllerProvider.notifier)
        .setConfirmScoreReset(false);

    final reloadedContainer = createContainer(storage);
    final reloadedState = await reloadedContainer.read(
      settingsControllerProvider.future,
    );

    expect(reloadedState.preferences.confirmScoreReset, isFalse);
  });
}
