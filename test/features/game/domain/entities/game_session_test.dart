import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_rules.dart';

void main() {
  test('Malenia defeat completes a No Mercy segment before max NG+', () {
    final session = GameSession.newGame(GameSetup.noMercy(CpuBossId.malenia))
        .copyWith(
          result: const GameResult.win(winner: Mark.x, winningCells: [2, 4, 6]),
        );

    expect(session.defeatedNoMercyFinalBoss, isTrue);
    expect(session.completedMaxNoMercyCycle, isFalse);
    expect(session.canAdvanceToNextNoMercyBoss, isTrue);
  });

  test('Malenia defeat completes the max No Mercy cycle at NG+4', () {
    final session =
        GameSession.newGame(
          GameSetup.noMercy(CpuBossId.malenia, noMercyCycle: maxNoMercyCycle),
        ).copyWith(
          result: const GameResult.win(winner: Mark.x, winningCells: [2, 4, 6]),
        );

    expect(session.defeatedNoMercyFinalBoss, isTrue);
    expect(session.completedMaxNoMercyCycle, isTrue);
    expect(session.canAdvanceToNextNoMercyBoss, isFalse);
  });

  test('non-Malenia boss defeat is not a No Mercy final boss defeat', () {
    final session = GameSession.newGame(GameSetup.noMercy(CpuBossId.radahn))
        .copyWith(
          result: const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
        );

    expect(session.defeatedNoMercyFinalBoss, isFalse);
    expect(session.completedMaxNoMercyCycle, isFalse);
    expect(session.canAdvanceToNextNoMercyBoss, isTrue);
  });
}
