import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/audio/domain/services/audio_controller.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/core/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/core/design_system/widgets/app_icon_button.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/router/app_routes.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/game_audio_effects.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/dialogs/game_over_dialog.dart';
import 'package:tictactoe/features/game/presentation/widgets/draw_critical_impact.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_board.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_player_badge.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_scene_backdrop.dart';
import 'package:tictactoe/features/game/presentation/widgets/solo_trial_banner.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

const _boardScreenRatio = 0.9;
const _boardAvailableRatio = 0.96;

class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);
    final audio = ref.read(audioControllerProvider);
    final audioEffects = GameAudioEffects(audio);
    final l10n = AppLocalizations.of(context);

    ref.listen(gameControllerProvider, (previous, next) {
      unawaited(
        audioEffects.playBoardDelta(
          previousBoard: previous?.session.board,
          nextBoard: next.session.board,
        ),
      );

      final result = next.session.result;
      if (result.isOngoing || previous?.session.result == result) {
        return;
      }

      unawaited(
        _runGameOverSequence(
          context: context,
          ref: ref,
          audio: audio,
          audioEffects: audioEffects,
          result: result,
          mode: next.session.mode,
        ),
      );
    });

    final compact = AppBreakpoints.isCompact(context);
    final horizontal = compact ? AppSpacing.lg : AppSpacing.xl;
    final activePlayer = _activePlayer(
      game.session.result,
      game.session.currentPlayer,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GameSceneBackdrop(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                AppSpacing.sm,
                horizontal,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => context.go(AppRoutes.homeLocation),
                        tooltip: l10n.homeTooltip,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GamePlayerBadge(
                            player: Player.cpu,
                            mode: game.session.mode,
                            active: activePlayer == Player.cpu,
                            side: GamePlayerBadgeSide.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenShortestSide = MediaQuery.sizeOf(
                          context,
                        ).shortestSide;
                        final targetDimension =
                            screenShortestSide * _boardScreenRatio;
                        final availableDimension =
                            math.min(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ) *
                            _boardAvailableRatio;
                        final dimension = math.min(
                          targetDimension,
                          availableDimension,
                        );

                        return Center(
                          child: SizedBox.square(
                            dimension: dimension,
                            child: GameBoard(
                              board: game.session.board,
                              result: game.session.result,
                              mode: game.session.mode,
                              onCellPressed: ref
                                  .read(gameControllerProvider.notifier)
                                  .playCell,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: GamePlayerBadge(
                      player: Player.human,
                      mode: game.session.mode,
                      active: activePlayer == Player.human,
                      side: GamePlayerBadgeSide.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SoloTrialBanner(mode: game.session.mode, result: game.session.result),
          if (game.session.result is GameDraw)
            DrawCriticalImpact(
              duration: GameAudioEffects.drawCriticalImpactDuration,
              trigger: game.session.board,
            ),
        ],
      ),
    );
  }

  Player? _activePlayer(GameResult result, Player currentPlayer) {
    return switch (result) {
      GameOngoing() => currentPlayer,
      GameWin(:final winner) => winner,
      GameDraw() => null,
    };
  }

  Future<void> _runGameOverSequence({
    required BuildContext context,
    required WidgetRef ref,
    required AudioController audio,
    required GameAudioEffects audioEffects,
    required GameResult result,
    required GameMode mode,
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) {
      return;
    }

    unawaited(audioEffects.playResultIntro(result, mode));
    await Future<void>.delayed(audioEffects.dialogDelayFor(result, mode));

    if (!context.mounted) {
      return;
    }

    unawaited(audioEffects.playDialogReveal(result, mode));
    await Future<void>.delayed(audioEffects.dialogRevealLeadFor(result, mode));

    if (!context.mounted) {
      return;
    }

    final choice = await GameOverDialog.show(
      context: context,
      result: result,
      mode: mode,
    );

    if (choice == GameOverChoice.playAgain) {
      unawaited(audio.playRestart());
      ref.read(gameControllerProvider.notifier).startNewRound();
    } else if (choice == GameOverChoice.home && context.mounted) {
      context.go(AppRoutes.homeLocation);
    }
  }
}
