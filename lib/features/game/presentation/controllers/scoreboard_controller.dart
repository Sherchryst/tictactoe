import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tictactoe/app/di/game_dependencies.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';

part 'scoreboard_controller.g.dart';

@Riverpod(keepAlive: true)
final class ScoreboardController extends _$ScoreboardController {
  @override
  Future<Scoreboard> build() {
    return ref.watch(loadScoreboardProvider).call();
  }

  Future<Scoreboard> record(GameOutcome outcome) async {
    final scoreboard = await ref.read(recordGameOutcomeProvider).call(outcome);
    state = AsyncData(scoreboard);
    return scoreboard;
  }

  Future<void> reset() async {
    await ref.read(resetScoreboardProvider).call();
    state = AsyncData(Scoreboard.empty());
  }
}
