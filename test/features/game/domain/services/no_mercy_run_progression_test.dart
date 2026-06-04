import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_progression.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_rules.dart';

void main() {
  const progression = NoMercyRunProgression();

  GameSession defeated(CpuBossId bossId, {int cycle = 0}) {
    return GameSession.newGame(
      GameSetup.noMercy(bossId, noMercyCycle: cycle),
    ).copyWith(
      result: const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
    );
  }

  test('advances to the next boss in the same cycle', () {
    final next = progression.nextAfterRound(defeated(CpuBossId.radahn));

    expect(next?.bossId, CpuBossId.mohg);
    expect(next?.noMercyCycle, 0);
  });

  test('enters next NG cycle after Malenia before max cycle', () {
    final next = progression.nextAfterRound(defeated(CpuBossId.malenia));

    expect(next?.bossId, CpuBossId.radahn);
    expect(next?.noMercyCycle, 1);
  });

  test('does not advance after max cycle Malenia', () {
    final next = progression.nextAfterRound(
      defeated(CpuBossId.malenia, cycle: maxNoMercyCycle),
    );

    expect(next, isNull);
  });

  test('prepares the saved continue session after a boss defeat', () {
    final nextSession = progression.sessionForContinue(
      defeated(CpuBossId.radahn),
    );

    expect(nextSession?.bossId, CpuBossId.mohg);
    expect(nextSession?.result.isOngoing, isTrue);
    expect(nextSession?.board.cells.every((mark) => mark == null), isTrue);
  });
}
