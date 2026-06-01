import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/game_dependencies.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/game_outcome.dart';
import '../../domain/entities/game_settings.dart';
import 'game_view_state.dart';

final gameControllerProvider = NotifierProvider<GameController, GameViewState>(
  GameController.new,
);

final class GameController extends Notifier<GameViewState> {
  @override
  GameViewState build() {
    return GameViewState.initial();
  }

  void startGame(GameSettings settings) {
    state = GameViewState(session: ref.read(startGameProvider).call(settings));
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
    state = previous.copyWith(
      session: session,
      hasRecordedOutcome: outcome != null || previous.hasRecordedOutcome,
    );

    if (outcome != null && !previous.hasRecordedOutcome) {
      unawaited(_recordOutcome(outcome));
    }
  }

  Future<void> _recordOutcome(GameOutcome outcome) async {
    final scoreboard = await ref.read(recordGameOutcomeProvider).call(outcome);
    if (!ref.mounted) {
      return;
    }

    ref.read(settingsControllerProvider.notifier).replaceScoreboard(scoreboard);
  }
}
