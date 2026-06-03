import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/app/di/audio_providers.dart';
import 'package:tictactoe/app/router/app_routes.dart';
import 'package:tictactoe/app/router/hero_tags.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_durations.dart';
import 'package:tictactoe/design_system/widgets/sigil_backdrop.dart';
import 'package:tictactoe/design_system/widgets/tic_tac_toe_title_logo.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/menu_sfx.dart';
import 'package:tictactoe/features/game/domain/entities/music_track.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/difficulty_dialog.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/home_entrance.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/home_menu_action.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/title_menu.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entranceController = useAnimationController(
      duration: AppDurations.cinematic,
    );
    final selectedAction = useState(HomeMenuAction.duel);
    final pressedAction = useState<HomeMenuAction?>(null);
    final transitioning = useState(false);
    final copy = GameCopy.of(context);

    Future<void> startGame(GameSetup setup) async {
      ref.read(gameControllerProvider.notifier).startGame(setup);

      if (context.mounted) {
        context.go(AppRoutes.gameLoadingLocation);
      }
    }

    Future<void> chooseAiDifficulty() async {
      final difficulty = await DifficultyDialog.show(context);
      if (!context.mounted || difficulty == null) {
        return;
      }

      await startGame(GameSetup(difficulty: difficulty));
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
        case HomeMenuAction.duel:
          await startGame(const GameSetup(mode: GameMode.humanVsHuman));
        case HomeMenuAction.solo:
          await chooseAiDifficulty();
        case HomeMenuAction.system:
          context.go(AppRoutes.settingsLocation);
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

    final screen = MediaQuery.sizeOf(context);
    final logoTop = screen.height * 0.15;
    final logoSideInset = (screen.shortestSide * 0.11)
        .clamp(38.0, 54.0)
        .toDouble();
    final logoFontSize = (screen.shortestSide * 0.15)
        .clamp(52.0, 64.0)
        .toDouble();
    final sigilSize = (screen.shortestSide * 1.18)
        .clamp(410.0, 540.0)
        .toDouble();
    final sigilTop = screen.height * 0.17;
    final menuTop = screen.height * 0.43;

    return Scaffold(
      body: ColoredBox(
        color: AppPalette.backgroundDeep,
        child: Stack(
          children: [
            Positioned(
              top: sigilTop,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.36,
                  child: SigilBackdrop(height: sigilSize),
                ),
              ),
            ),
            Positioned(
              top: logoTop,
              left: logoSideInset,
              right: logoSideInset,
              child: Hero(
                tag: HeroTags.titleLogo,
                child: TicTacToeTitleLogo(fontSize: logoFontSize),
              ),
            ),
            Positioned(
              top: menuTop,
              left: 0,
              right: 0,
              height: TitleMenu.totalHeight,
              child: HomeEntrance(
                animation: entranceController,
                begin: 0.34,
                end: 0.92,
                offset: const Offset(0, 24),
                child: TitleMenu(
                  copy: copy,
                  selectedAction: selectedAction.value,
                  pressedAction: pressedAction.value,
                  onSelected: handleMenuSelection,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
