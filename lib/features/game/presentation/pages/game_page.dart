import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tictactoe/app/di/audio_providers.dart';
import 'package:tictactoe/app/router/app_routes.dart';
import 'package:tictactoe/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/design_system/tokens/app_typography.dart';
import 'package:tictactoe/design_system/widgets/app_icon_button.dart';
import 'package:tictactoe/design_system/widgets/rune_diamond.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/audio_controller.dart';
import 'package:tictactoe/features/game/domain/services/game_audio_effects.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/dialogs/game_over_dialog.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';
import 'package:tictactoe/features/game/presentation/widgets/draw_critical_impact.dart';
import 'package:tictactoe/features/game/presentation/widgets/duel_ribbon.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_board.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_scene_backdrop.dart';
import 'package:tictactoe/features/game/presentation/widgets/solo_trial_banner.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);
    final audio = ref.read(audioControllerProvider);
    final audioEffects = GameAudioEffects(audio);
    final copy = GameCopy.of(context);

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
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => context.go(AppRoutes.homeLocation),
                        tooltip: copy.homeTooltip,
                      ),
                      const Spacer(),
                      _ModeMark(label: copy.gameModeTitle(game.session.mode)),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppBreakpoints.boardMaxWidth,
                        ),
                        child: GameBoard(
                          board: game.session.board,
                          result: game.session.result,
                          onCellPressed: ref
                              .read(gameControllerProvider.notifier)
                              .playCell,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
                  DuelRibbon(
                    mode: game.session.mode,
                    activePlayer: _activePlayer(
                      game.session.result,
                      game.session.currentPlayer,
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

class _ModeMark extends StatelessWidget {
  const _ModeMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const RuneDiamond(size: 4),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTypography.of(context).chromeMark(active: true)),
      ],
    );
  }
}
