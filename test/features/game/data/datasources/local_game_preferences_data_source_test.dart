import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/features/game/data/datasources/game_storage_keys.dart';
import 'package:tictactoe/features/game/data/datasources/local_game_preferences_data_source.dart';
import 'package:tictactoe/features/game/data/models/app_preferences_dto.dart';
import 'package:tictactoe/features/game/data/models/scoreboard_dto.dart';
import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';

import 'package:tictactoe/testing/mocks.mocks.dart';

void main() {
  late MockKeyValueStorage storage;
  late LocalGamePreferencesDataSource dataSource;

  setUp(() {
    storage = MockKeyValueStorage();
    dataSource = LocalGamePreferencesDataSource(storage);
  });

  group('LocalGamePreferencesDataSource', () {
    test('returns null when saved preferences json is invalid', () async {
      when(
        storage.readString(GameStorageKeys.preferences),
      ).thenAnswer((_) async => 'not-json');

      expect(await dataSource.loadPreferences(), isNull);
      verify(storage.readString(GameStorageKeys.preferences)).called(1);
      verifyNoMoreInteractions(storage);
    });

    test('returns null when saved scoreboard json is incomplete', () async {
      when(
        storage.readString(GameStorageKeys.scoreboard),
      ).thenAnswer((_) async => '{"humanWins":1}');

      expect(await dataSource.loadScoreboard(), isNull);
      verify(storage.readString(GameStorageKeys.scoreboard)).called(1);
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
                  storage.writeString(GameStorageKeys.preferences, captureAny),
                ).captured.single
                as String;
        expect(jsonDecode(capturedJson), {'localePreference': 'french'});
        verifyNoMoreInteractions(storage);
      },
    );

    test(
      'writes serialized scoreboard to the scoreboard storage key',
      () async {
        when(storage.writeString(any, any)).thenAnswer((_) async {});

        await dataSource.saveScoreboard(
          const ScoreboardDto(humanWins: 2, cpuWins: 1, draws: 3),
        );

        final capturedJson =
            verify(
                  storage.writeString(GameStorageKeys.scoreboard, captureAny),
                ).captured.single
                as String;
        expect(jsonDecode(capturedJson), {
          'humanWins': 2,
          'cpuWins': 1,
          'draws': 3,
        });
        verifyNoMoreInteractions(storage);
      },
    );
  });
}
