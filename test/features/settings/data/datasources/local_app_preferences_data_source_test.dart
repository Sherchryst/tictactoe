import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/features/settings/data/datasources/local_app_preferences_data_source.dart';
import 'package:tictactoe/features/settings/data/models/app_preferences_dto.dart';
import 'package:tictactoe/features/settings/domain/entities/app_preferences.dart';

import '../../../../testing/mocks.mocks.dart';

void main() {
  late MockKeyValueStorage storage;
  late LocalAppPreferencesDataSource dataSource;

  setUp(() {
    storage = MockKeyValueStorage();
    dataSource = LocalAppPreferencesDataSource(storage);
  });

  group('LocalAppPreferencesDataSource', () {
    test('returns null when saved preferences json is invalid', () async {
      when(
        storage.readString('app_preferences'),
      ).thenAnswer((_) async => 'not-json');

      expect(await dataSource.loadPreferences(), isNull);
      verify(storage.readString('app_preferences')).called(1);
      verifyNoMoreInteractions(storage);
    });

    test(
      'writes serialized preferences to the preferences storage key',
      () async {
        when(storage.writeString(any, any)).thenAnswer((_) async {});

        await dataSource.savePreferences(
          const AppPreferencesDto(localePreference: AppLocalePreference.french),
        );

        final capturedJson =
            verify(
                  storage.writeString('app_preferences', captureAny),
                ).captured.single
                as String;
        expect(jsonDecode(capturedJson), {'localePreference': 'french'});
        verifyNoMoreInteractions(storage);
      },
    );
  });
}
