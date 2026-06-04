import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';

final class StartNewRound {
  const StartNewRound();

  GameSession call(
    GameSession session, {
    CpuBossId? bossId,
    int? noMercyCycle,
  }) {
    return session.startNewRound(bossId: bossId, noMercyCycle: noMercyCycle);
  }
}
