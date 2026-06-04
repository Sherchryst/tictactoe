import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';

final class BossPattern {
  const BossPattern({
    required this.bossId,
    required this.noMercyCycle,
    required this.humanMoves,
    required this.cpuMoves,
  });

  final CpuBossId bossId;
  final int noMercyCycle;
  final List<int> humanMoves;
  final List<int> cpuMoves;

  bool matchesHumanPrefix(List<int> moves) {
    if (moves.length > humanMoves.length) {
      return false;
    }

    for (var index = 0; index < moves.length; index++) {
      if (moves[index] != humanMoves[index]) {
        return false;
      }
    }

    return true;
  }

  int? scriptedCpuMove(int playedCpuMoves) {
    if (playedCpuMoves >= cpuMoves.length) {
      return null;
    }

    return cpuMoves[playedCpuMoves];
  }

  String get debugName {
    return noMercyCycle == 0 ? bossId.name : '${bossId.name} NG+$noMercyCycle';
  }
}
