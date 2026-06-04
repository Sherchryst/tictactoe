import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/features/game/data/datasources/local_no_mercy_run_data_source.dart';
import 'package:tictactoe/features/game/data/models/no_mercy_run_dto.dart';

import '../../../../testing/mocks.mocks.dart';

void main() {
  late MockKeyValueStorage storage;
  late LocalNoMercyRunDataSource dataSource;

  setUp(() {
    storage = MockKeyValueStorage();
    dataSource = LocalNoMercyRunDataSource(storage);
  });

  group('LocalNoMercyRunDataSource', () {
    test('returns null for corrupt saved run data', () async {
      when(storage.readString('no_mercy_run_v1')).thenAnswer(
        (_) async => jsonEncode({..._validRunJson(), 'bossId': 'guided'}),
      );

      expect(await dataSource.loadRun(), isNull);
      verify(storage.readString('no_mercy_run_v1')).called(1);
      verifyNoMoreInteractions(storage);
    });

    test('writes serialized run to the No Mercy storage key', () async {
      when(storage.writeString(any, any)).thenAnswer((_) async {});

      await dataSource.saveRun(NoMercyRunDto.fromJson(_validRunJson()));

      final capturedJson =
          verify(
                storage.writeString('no_mercy_run_v1', captureAny),
              ).captured.single
              as String;
      expect(jsonDecode(capturedJson), _validRunJson());
      verifyNoMoreInteractions(storage);
    });
  });
}

Map<String, Object?> _validRunJson() {
  return {
    'cells': ['x', 'x', 'x', 'o', 'o', null, null, null, null],
    'currentMark': 'x',
    'bossId': 'radahn',
    'noMercyCycle': 0,
    'weaknessBroken': false,
    'humanMoves': [0, 1, 2],
    'cpuMoves': [3, 4],
    'resultType': 'win',
    'winner': 'x',
    'winningCells': [0, 1, 2],
  };
}
