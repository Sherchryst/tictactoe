import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/features/game/data/datasources/local_scoreboard_data_source.dart';
import 'package:tictactoe/features/game/data/models/scoreboard_dto.dart';

import '../../../../testing/mocks.mocks.dart';

void main() {
  late MockKeyValueStorage storage;
  late LocalScoreboardDataSource dataSource;

  setUp(() {
    storage = MockKeyValueStorage();
    dataSource = LocalScoreboardDataSource(storage);
  });

  group('LocalScoreboardDataSource', () {
    test('returns null when saved scoreboard json is incomplete', () async {
      when(
        storage.readString('scoreboard'),
      ).thenAnswer((_) async => '{"humanWins":1}');

      expect(await dataSource.loadScoreboard(), isNull);
      verify(storage.readString('scoreboard')).called(1);
      verifyNoMoreInteractions(storage);
    });

    test(
      'writes serialized scoreboard to the scoreboard storage key',
      () async {
        when(storage.writeString(any, any)).thenAnswer((_) async {});

        await dataSource.saveScoreboard(
          const ScoreboardDto(humanWins: 2, cpuWins: 1, draws: 3),
        );

        final capturedJson =
            verify(
                  storage.writeString('scoreboard', captureAny),
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
