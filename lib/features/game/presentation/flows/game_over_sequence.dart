import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/router/app_routes.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/presentation/audio/game_audio_effects.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/dialogs/ending_credits_roll.dart';
import 'package:tictactoe/features/game/presentation/dialogs/game_over_dialog.dart';

Future<void> runGameOverSequence({
  required BuildContext context,
  required WidgetRef ref,
  required GameAudioEffects audioEffects,
  required GameSession session,
}) async {
  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) {
    return;
  }

  unawaited(audioEffects.playResultIntro(session));
  await Future<void>.delayed(audioEffects.dialogDelayFor(session));

  if (!context.mounted) {
    return;
  }

  unawaited(audioEffects.playDialogReveal(session));
  await Future<void>.delayed(audioEffects.dialogRevealLeadFor(session));

  if (!context.mounted) {
    return;
  }

  if (session.defeatedNoMercyFinalBoss) {
    await EndingCreditsRoll.show(context: context);
    if (!context.mounted) {
      return;
    }
  }

  final choice = await GameOverDialog.show(context: context, session: session);
  if (!context.mounted) {
    return;
  }

  switch (choice) {
    case GameOverChoice.nextBoss:
      await _advanceNoMercyThenShowLoading(context, ref);
    case GameOverChoice.newGamePlus:
      await _startNewGamePlusThenShowLoading(context, ref, session);
    case GameOverChoice.titleScreen:
      context.go(AppRoutes.titleLocation);
    case GameOverChoice.playAgain:
      unawaited(ref.read(audioControllerProvider).playRestart());
      unawaited(ref.read(gameControllerProvider.notifier).startNewRound());
    case GameOverChoice.home:
      context.go(AppRoutes.homeLocation);
    case null:
      break;
  }
}

Future<void> _advanceNoMercyThenShowLoading(
  BuildContext context,
  WidgetRef ref,
) async {
  unawaited(ref.read(audioControllerProvider).playRestart());
  final gameController = ref.read(gameControllerProvider.notifier);

  final advanced = await gameController.advanceNoMercyRun();
  if (!context.mounted) {
    return;
  }

  context.go(advanced ? AppRoutes.gameLoadingLocation : AppRoutes.homeLocation);
}

Future<void> _startNewGamePlusThenShowLoading(
  BuildContext context,
  WidgetRef ref,
  GameSession session,
) async {
  unawaited(ref.read(audioControllerProvider).playRestart());
  final gameController = ref.read(gameControllerProvider.notifier);

  if (session.completedMaxNoMercyCycle) {
    await gameController.restartNoMercyRun();
    if (context.mounted) {
      context.go(AppRoutes.gameLoadingLocation);
    }

    return;
  }

  final advanced = await gameController.advanceNoMercyRun();
  if (!context.mounted) {
    return;
  }

  context.go(advanced ? AppRoutes.gameLoadingLocation : AppRoutes.homeLocation);
}
