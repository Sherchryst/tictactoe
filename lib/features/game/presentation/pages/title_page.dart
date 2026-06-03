import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tictactoe/app/di/audio_providers.dart';
import 'package:tictactoe/app/router/app_routes.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_durations.dart';
import 'package:tictactoe/design_system/widgets/ambient_motes.dart';
import 'package:tictactoe/features/game/domain/entities/menu_sfx.dart';
import 'package:tictactoe/features/game/domain/entities/music_track.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';
import 'package:tictactoe/features/game/presentation/widgets/title/title_background.dart';
import 'package:tictactoe/features/game/presentation/widgets/title/title_logo_intro.dart';
import 'package:tictactoe/features/game/presentation/widgets/title/title_touch_prompt.dart';

class TitlePage extends HookConsumerWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundController = useAnimationController(
      duration: AppDurations.titleBackground,
    );
    final logoController = useAnimationController(
      duration: AppDurations.titleLogo,
    );
    final promptController = useAnimationController(
      duration: AppDurations.titlePrompt,
    );
    final pressController = useAnimationController(
      duration: AppDurations.titlePress,
    );
    final motesController = useAnimationController(
      duration: AppDurations.titleMotesLoop,
    );
    final promptVisible = useState(false);
    final opening = useState(false);

    void revealPrompt() {
      if (promptVisible.value) {
        return;
      }
      promptVisible.value = true;
      unawaited(promptController.forward());
    }

    Future<void> startTitleSequence() async {
      unawaited(ref.read(audioControllerProvider).playTrack(MusicTrack.menu));
      unawaited(backgroundController.forward());
      await Future<void>.delayed(AppDurations.titleLogoEntranceDelay);
      if (!context.mounted) {
        return;
      }

      unawaited(logoController.forward());
      await Future<void>.delayed(AppDurations.titlePromptDelay);
      if (!context.mounted) {
        return;
      }

      revealPrompt();
    }

    Future<void> handlePress() async {
      if (opening.value) {
        return;
      }

      if (!promptVisible.value) {
        unawaited(logoController.forward());
        revealPrompt();
        return;
      }

      opening.value = true;
      unawaited(
        ref.read(audioControllerProvider).playMenuSfx(MenuSfx.activate),
      );
      await pressController.forward(from: 0);
      await Future<void>.delayed(AppDurations.titleRouteHandoff);
      if (!context.mounted) {
        return;
      }

      context.go(AppRoutes.homeLocation);
    }

    useEffect(() {
      unawaited(motesController.repeat());
      unawaited(startTitleSequence());

      return null;
    }, const []);

    final screen = MediaQuery.sizeOf(context);
    final copy = GameCopy.of(context);
    final logoTop = screen.height * 0.31;
    final sigilSize = (screen.shortestSide * 1.26).clamp(430.0, 650.0);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: handlePress,
        child: ColoredBox(
          color: AppPalette.backgroundDeep,
          child: RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AmbientMotes(controller: motesController),
                TitleBackground(
                  controller: backgroundController,
                  sigilTop: screen.height * 0.17,
                  sigilSize: sigilSize,
                ),
                Positioned(
                  top: logoTop,
                  left: 20,
                  right: 20,
                  child: TitleLogoIntro(controller: logoController),
                ),
                if (promptVisible.value)
                  Positioned(
                    top: logoTop + screen.height * 0.18,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: promptController,
                      child: TitleTouchPrompt(
                        label: copy.touchScreenPrompt,
                        pressAnimation: pressController,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
