import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/core/preferences/application/controllers/app_preferences_controller.dart';
import 'package:tictactoe/core/preferences/domain/entities/app_preferences.dart';

import '../../../../testing/in_memory_key_value_storage.dart';
import '../../../../testing/provider_container_factory.dart';

void main() {
  test('loads default preferences', () async {
    final container = createTestContainer(
      registerTearDown: addTearDown,
      overrides: [
        keyValueStorageProvider.overrideWithValue(InMemoryKeyValueStorage()),
      ],
    );

    final preferences = await container.read(
      appPreferencesControllerProvider.future,
    );

    expect(preferences, AppPreferences.defaults());
  });

  test('updates and persists shared preferences', () async {
    final storage = InMemoryKeyValueStorage();
    final firstContainer = createTestContainer(
      registerTearDown: addTearDown,
      overrides: [keyValueStorageProvider.overrideWithValue(storage)],
    );

    await firstContainer.read(appPreferencesControllerProvider.future);
    await firstContainer
        .read(appPreferencesControllerProvider.notifier)
        .setLocalePreference(AppLocalePreference.german);
    await firstContainer
        .read(appPreferencesControllerProvider.notifier)
        .setConfirmScoreReset(false);

    final secondContainer = createTestContainer(
      registerTearDown: addTearDown,
      overrides: [keyValueStorageProvider.overrideWithValue(storage)],
    );
    final preferences = await secondContainer.read(
      appPreferencesControllerProvider.future,
    );

    expect(preferences.localePreference, AppLocalePreference.german);
    expect(preferences.confirmScoreReset, isFalse);
  });
}
