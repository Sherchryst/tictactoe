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
    test('ignores the old scoreboard storage key', () async {
      when(
        storage.readString('no_mercy_scoreboard_v1'),
      ).thenAnswer((_) async => null);

      expect(await dataSource.loadScoreboard(), isNull);
      verify(storage.readString('no_mercy_scoreboard_v1')).called(1);
      verifyNoMoreInteractions(storage);
    });

    test('writes serialized scoreboard to the No Mercy storage key', () async {
      when(storage.writeString(any, any)).thenAnswer((_) async {});

      await dataSource.saveScoreboard(
        const ScoreboardDto(
          radahn: BossScoreDto(attempts: 2, humanWins: 1, cpuWins: 1, draws: 0),
          mohg: BossScoreDto(attempts: 1, humanWins: 0, cpuWins: 0, draws: 1),
          malenia: BossScoreDto(
            attempts: 0,
            humanWins: 0,
            cpuWins: 0,
            draws: 0,
          ),
        ),
      );

      final capturedJson =
          verify(
                storage.writeString('no_mercy_scoreboard_v1', captureAny),
              ).captured.single
              as String;
      expect(jsonDecode(capturedJson), {
        'radahn': {'attempts': 2, 'humanWins': 1, 'cpuWins': 1, 'draws': 0},
        'mohg': {'attempts': 1, 'humanWins': 0, 'cpuWins': 0, 'draws': 1},
        'malenia': {'attempts': 0, 'humanWins': 0, 'cpuWins': 0, 'draws': 0},
      });
      verifyNoMoreInteractions(storage);
    });
  });
}
