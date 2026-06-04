import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_rules.dart';

typedef NoMercyProgression = ({CpuBossId bossId, int noMercyCycle});

final class NoMercyRunProgression {
  const NoMercyRunProgression();

  NoMercyProgression? nextAfterRound(GameSession session) {
    if (!session.isNoMercy ||
        session.participantOutcome != GameOutcome.humanWin) {
      return null;
    }

    final nextBoss = session.bossId.nextNoMercyBoss;
    if (nextBoss != null) {
      return (bossId: nextBoss, noMercyCycle: session.noMercyCycle);
    }

    if (session.bossId == CpuBossId.malenia &&
        session.noMercyCycle < maxNoMercyCycle) {
      return (bossId: CpuBossId.radahn, noMercyCycle: session.noMercyCycle + 1);
    }

    return null;
  }

  GameSession? sessionForContinue(GameSession session) {
    if (!session.isNoMercy || session.completedMaxNoMercyCycle) {
      return null;
    }

    final nextProgression = nextAfterRound(session);
    if (nextProgression != null) {
      return session.startNewRound(
        bossId: nextProgression.bossId,
        noMercyCycle: nextProgression.noMercyCycle,
      );
    }

    if (!session.result.isOngoing) {
      return session.startNewRound();
    }

    return session;
  }
}
