import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictactoe/core/di/game_dependencies.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_view_state.dart';
import 'package:tictactoe/features/game/presentation/controllers/scoreboard_controller.dart';

part 'game_controller.g.dart';

@Riverpod(keepAlive: true)
final class GameController extends _$GameController {
  @override
  GameViewState build() => GameViewState.initial();

  void startGame(GameSetup setup) {
    state = GameViewState(session: ref.read(startGameProvider).call(setup));
  }

  void startNewRound() {
    state = state.copyWith(
      session: ref.read(startNewRoundProvider).call(state.session),
      hasRecordedOutcome: false,
    );
  }

  void playCell(int cellIndex) {
    final previous = state;
    final session = ref
        .read(playHumanMoveProvider)
        .call(previous.session, cellIndex);

    if (session == previous.session) {
      return;
    }

    final outcome = session.result.outcome;
    final shouldRecordOutcome =
        outcome != null && previous.session.mode == GameMode.humanVsCpu;
    state = previous.copyWith(
      session: session,
      hasRecordedOutcome: shouldRecordOutcome || previous.hasRecordedOutcome,
    );

    if (shouldRecordOutcome && !previous.hasRecordedOutcome) {
      unawaited(_recordOutcome(outcome));
    }
  }

  Future<void> _recordOutcome(GameOutcome outcome) async {
    await ref.read(scoreboardControllerProvider.notifier).record(outcome);
  }
}
