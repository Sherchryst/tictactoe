import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/audio/domain/entities/menu_sfx.dart';
import 'package:tictactoe/core/audio/domain/entities/music_track.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/router/app_routes.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/controllers/no_mercy_run_status.dart';
import 'package:tictactoe/features/game/presentation/dialogs/difficulty_dialog.dart';
import 'package:tictactoe/features/game/presentation/dialogs/ending_credits_roll.dart';
import 'package:tictactoe/features/game/presentation/dialogs/reset_no_mercy_run_dialog.dart';
import 'package:tictactoe/features/game/presentation/dialogs/scoreboard_dialog.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/home_menu_action.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/home_scene.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/new_game_choice.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entranceController = useAnimationController(
      duration: AppDurations.cinematic,
    );
    final selectedAction = useState(
      firstHomeMenuAction(showContinue: false, showCredits: false),
    );
    final pressedAction = useState<HomeMenuAction?>(null);
    final transitioning = useState(false);
    final runStatus = ref.watch(noMercyRunStatusProvider).value;
    final hasSavedRun = runStatus?.hasSavedRun ?? false;
    final showCredits = runStatus?.creditsUnlocked ?? false;
    final firstVisibleAction = firstHomeMenuAction(
      showContinue: hasSavedRun,
      showCredits: showCredits,
    );

    useEffect(() {
      selectedAction.value = firstVisibleAction;

      return null;
    }, [firstVisibleAction]);

    Future<void> openGame() async {
      final challenge = await DifficultyDialog.show(context);
      if (!context.mounted || challenge == null) {
        return;
      }

      switch (challenge) {
        case NewGameChoice.guided:
          await ref.read(gameControllerProvider.notifier).startGuidedTrial();
        case NewGameChoice.noMercy:
          final shouldReset =
              !hasSavedRun || await ResetNoMercyRunDialog.show(context);
          if (!context.mounted || !shouldReset) {
            return;
          }

          final gameController = ref.read(gameControllerProvider.notifier);
          if (hasSavedRun) {
            await gameController.restartNoMercyRun();
          } else {
            await gameController.startNoMercyRun();
          }
      }

      if (context.mounted) {
        context.go(AppRoutes.gameLoadingLocation);
      }
    }

    Future<void> continueNoMercyRun() async {
      final continued = await ref
          .read(gameControllerProvider.notifier)
          .continueNoMercyRun();
      if (continued && context.mounted) {
        context.go(AppRoutes.gameLoadingLocation);
      }
    }

    Future<void> handleMenuSelection(HomeMenuAction action) async {
      if (transitioning.value) {
        return;
      }

      transitioning.value = true;
      selectedAction.value = action;
      pressedAction.value = action;
      unawaited(ref.read(audioControllerProvider).playMenuSfx(MenuSfx.select));

      await Future<void>.delayed(AppDurations.menuActionHold);
      if (!context.mounted) {
        return;
      }

      pressedAction.value = null;

      switch (action) {
        case HomeMenuAction.continueRun:
          await continueNoMercyRun();
        case HomeMenuAction.duel:
          await ref.read(gameControllerProvider.notifier).startLocalDuel();
          if (context.mounted) {
            context.go(AppRoutes.gameLoadingLocation);
          }
        case HomeMenuAction.solo:
          await openGame();
        case HomeMenuAction.score:
          await ScoreboardDialog.show(context);
        case HomeMenuAction.system:
          context.go(AppRoutes.settingsLocation);
        case HomeMenuAction.credits:
          await EndingCreditsRoll.show(
            context: context,
            onComplete: () => context.go(AppRoutes.titleFromCreditsLocation),
          );
      }

      if (context.mounted) {
        transitioning.value = false;
      }
    }

    useEffect(() {
      unawaited(entranceController.forward());
      unawaited(ref.read(audioControllerProvider).playTrack(MusicTrack.menu));

      return null;
    }, const []);

    return HomeScene(
      title: l10n.appTitle,
      entrance: entranceController,
      selectedAction: selectedAction.value,
      pressedAction: pressedAction.value,
      onSelected: handleMenuSelection,
      showContinue: hasSavedRun,
      showCredits: showCredits,
    );
  }
}
