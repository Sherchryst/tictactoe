import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/settings/data/datasources/local_app_preferences_data_source.dart';
import 'package:tictactoe/features/settings/data/repositories/local_app_preferences_repository.dart';
import 'package:tictactoe/features/settings/domain/entities/app_preferences.dart';

import '../../../../testing/in_memory_key_value_storage.dart';

void main() {
  late InMemoryKeyValueStorage storage;
  late LocalAppPreferencesRepository repository;

  setUp(() {
    storage = InMemoryKeyValueStorage();
    repository = LocalAppPreferencesRepository(
      LocalAppPreferencesDataSource(storage),
    );
  });

  test('returns default preferences when none are saved', () async {
    expect(await repository.load(), AppPreferences.defaults());
  });

  test('returns default preferences when saved json is invalid', () async {
    await storage.writeString('app_preferences', 'not-json');

    expect(await repository.load(), AppPreferences.defaults());
  });

  test('returns default preferences when saved locale is unknown', () async {
    await storage.writeString(
      'app_preferences',
      '{"localePreference":"klingon"}',
    );

    expect(await repository.load(), AppPreferences.defaults());
  });

  test('saves and loads preferences', () async {
    const preferences = AppPreferences(
      localePreference: AppLocalePreference.french,
    );

    await repository.save(preferences);

    expect(await repository.load(), preferences);
  });

  test('serializes concurrent saves', () async {
    const first = AppPreferences(localePreference: AppLocalePreference.french);
    const second = AppPreferences(
      localePreference: AppLocalePreference.spanish,
    );
    const third = AppPreferences(localePreference: AppLocalePreference.german);

    await Future.wait([
      repository.save(first),
      repository.save(second),
      repository.save(third),
    ]);

    expect(await repository.load(), third);
  });
}
