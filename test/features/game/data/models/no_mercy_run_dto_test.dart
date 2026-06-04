import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/data/models/no_mercy_run_dto.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';

void main() {
  group('NoMercyRunDto', () {
    test('round-trips a valid No Mercy win', () {
      final run = NoMercyRunDto.fromJson(_validWinJson()).toDomain();

      expect(run.bossId, CpuBossId.radahn);
      expect(run.currentMark, Mark.x);
      expect(run.humanMoves, [0, 1, 2]);
      expect(run.cpuMoves, [3, 4]);
      expect(
        run.result,
        const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
      );
    });

    test('rejects unknown bosses instead of defaulting to Radahn', () {
      expect(
        () => NoMercyRunDto.fromJson({..._validWinJson(), 'bossId': 'guided'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects duplicated moves', () {
      expect(
        () => NoMercyRunDto.fromJson({
          ..._validWinJson(),
          'humanMoves': [0, 1, 1],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects moves outside the board', () {
      expect(
        () => NoMercyRunDto.fromJson({
          ..._validWinJson(),
          'cpuMoves': [3, 9],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects result data that does not match the board', () {
      expect(
        () => NoMercyRunDto.fromJson({
          ..._validWinJson(),
          'cells': ['x', 'o', 'x', 'o', 'x', null, null, null, null],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

Map<String, Object?> _validWinJson() {
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
