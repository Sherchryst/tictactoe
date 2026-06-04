import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/services/boss_pattern_catalog.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/minimax_cpu_strategy.dart';

final class BossPuzzleCpuStrategy implements CpuStrategy {
  const BossPuzzleCpuStrategy({
    MinimaxCpuStrategy fallbackStrategy = const MinimaxCpuStrategy(),
  }) : _fallbackStrategy = fallbackStrategy;

  final MinimaxCpuStrategy _fallbackStrategy;

  @override
  int chooseMove(GameSession session) {
    final pattern = BossPatterns.forBoss(
      session.bossId,
      noMercyCycle: session.noMercyCycle,
    );
    if (pattern == null || session.weaknessBroken) {
      return _fallbackStrategy.chooseMove(session);
    }

    final scriptedMove = pattern.scriptedCpuMove(session.cpuMoves.length);
    if (scriptedMove != null && session.board.canPlace(scriptedMove)) {
      return scriptedMove;
    }

    return _fallbackStrategy.chooseMove(session);
  }
}
