import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/data/models/app_preferences_dto.dart';
import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';

void main() {
  test('maps preferences between domain and json', () {
    const preferences = AppPreferences(
      localePreference: AppLocalePreference.spanish,
    );

    final json = AppPreferencesDto.fromDomain(preferences).toJson();
    final mappedPreferences = AppPreferencesDto.fromJson(json).toDomain();

    expect(mappedPreferences, preferences);
  });

  test('defaults missing locale', () {
    final preferences = AppPreferencesDto.fromJson(const {}).toDomain();

    expect(preferences.localePreference, AppLocalePreference.english);
  });
}
