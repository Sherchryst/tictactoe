import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/core/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/core/design_system/widgets/app_icon_button.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/router/app_routes.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/utils/audio/game_audio_effects.dart';
import 'package:tictactoe/features/game/presentation/utils/flows/game_over_sequence.dart';
import 'package:tictactoe/features/game/presentation/utils/navigation/game_route_guard.dart';
import 'package:tictactoe/features/game/presentation/utils/styles/game_layout_metrics.dart';
import 'package:tictactoe/features/game/presentation/utils/styles/game_player_badge_types.dart';
import 'package:tictactoe/features/game/presentation/widgets/boss_rune_intro.dart';
import 'package:tictactoe/features/game/presentation/widgets/draw_critical_impact.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_board.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_player_badge.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_scene_backdrop.dart';
import 'package:tictactoe/features/game/presentation/widgets/no_mercy_cycle_badge.dart';
import 'package:tictactoe/features/game/presentation/widgets/solo_trial_banner.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class GamePage extends HookConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);
    final audio = ref.read(audioControllerProvider);
    final audioEffects = GameAudioEffects(audio);
    final l10n = AppLocalizations.of(context);
    final sessionIdentity = identityHashCode(game.session);
    final introShouldAnimate = BossRuneIntro.shouldAnimateSession(game.session);
    final bossIntroActive = useState(introShouldAnimate);

    useEffect(() {
      bossIntroActive.value = introShouldAnimate;
      return null;
    }, [sessionIdentity, introShouldAnimate]);

    ref.listen(gameControllerProvider, (previous, next) {
      unawaited(
        audioEffects.playBoardDelta(
          previousBoard: previous?.session.board,
          nextSession: next.session,
        ),
      );

      final result = next.session.result;
      if (result.isOngoing || previous?.session.result == result) {
        return;
      }

      unawaited(
        runGameOverSequence(
          context: context,
          ref: ref,
          audioEffects: audioEffects,
          session: next.session,
        ),
      );
    });

    final compact = AppBreakpoints.isCompact(context);
    final horizontal = compact ? AppSpacing.lg : AppSpacing.xl;
    final activeMark = _activeMark(
      game.session.result,
      game.session.currentMark,
    );

    return GameRouteGuard(
      state: game,
      child: Scaffold(
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
                              participant: game.session.participantFor(
                                game.session.opponentMark,
                              ),
                              session: game.session,
                              active: activeMark == game.session.opponentMark,
                              side: GamePlayerBadgeSide.right,
                              visible: !bossIntroActive.value,
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
                              screenShortestSide *
                              GameLayoutMetrics.boardScreenRatio;
                          final availableDimension =
                              math.min(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ) *
                              GameLayoutMetrics.boardAvailableRatio;
                          final dimension = math.min(
                            targetDimension,
                            availableDimension,
                          );

                          return Center(
                            child: SizedBox.square(
                              dimension: dimension,
                              child: GameBoard(
                                session: game.session,
                                phase: game.phase,
                                onCellPressed: ref
                                    .read(gameControllerProvider.notifier)
                                    .playCell,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: GamePlayerBadge(
                              participant: game.session.participantFor(
                                game.session.humanMark,
                              ),
                              session: game.session,
                              active: activeMark == game.session.humanMark,
                              side: GamePlayerBadgeSide.left,
                            ),
                          ),
                        ),
                        if (game.session.isNoMercy &&
                            game.session.noMercyCycle > 0)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.md,
                              bottom: AppSpacing.xs,
                            ),
                            child: NoMercyCycleBadge(
                              cycle: game.session.noMercyCycle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            BossRuneIntro(
              session: game.session,
              animationKey: sessionIdentity,
              onSeal: () {
                unawaited(audioEffects.playBossRuneIntro(game.session));
              },
              onComplete: () {
                bossIntroActive.value = false;
              },
            ),
            SoloTrialBanner(session: game.session),
            if (game.session.result is GameDraw)
              DrawCriticalImpact(
                duration: GameAudioEffects.drawCriticalImpactDuration,
                trigger: game.session.board,
              ),
          ],
        ),
      ),
    );
  }

  Mark? _activeMark(GameResult result, Mark currentMark) {
    return switch (result) {
      GameOngoing() => currentMark,
      GameWin(:final winner) => winner,
      GameDraw() => null,
    };
  }
}
