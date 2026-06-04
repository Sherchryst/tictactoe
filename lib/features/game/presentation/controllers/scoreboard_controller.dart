import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tictactoe/core/di/game_dependencies.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';

part 'scoreboard_controller.g.dart';

@Riverpod(keepAlive: true)
final class ScoreboardController extends _$ScoreboardController {
  @override
  Future<Scoreboard> build() {
    return ref.watch(loadScoreboardProvider).call();
  }

  Future<Scoreboard> record(CpuBossId bossId, GameOutcome outcome) async {
    final scoreboard = await ref
        .read(recordGameOutcomeProvider)
        .call(bossId, outcome);
    state = AsyncData(scoreboard);
    return scoreboard;
  }

  Future<Scoreboard?> recordNoMercyOutcome(GameSession session) async {
    final scoreboard = await ref
        .read(recordNoMercyOutcomeProvider)
        .call(session);
    if (scoreboard != null) {
      state = AsyncData(scoreboard);
    }

    return scoreboard;
  }

  Future<void> reset() async {
    await ref.read(resetScoreboardProvider).call();
    state = AsyncData(Scoreboard.empty());
  }
}
