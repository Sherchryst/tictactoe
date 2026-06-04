import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tictactoe/core/design_system/tokens/app_animations.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/core/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/presentation/audio/game_audio_effects.dart';
import 'package:tictactoe/features/game/presentation/utils/bosses/boss_presentation.dart';
import 'package:tictactoe/features/game/presentation/utils/rendering/boss_rune_intro_glow_painter.dart';
import 'package:tictactoe/features/game/presentation/widgets/boss_rune_reveal_visual.dart';
import 'package:tictactoe/features/game/presentation/widgets/boss_rune_widget_keys.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_player_badge.dart';

class BossRuneIntro extends HookWidget {
  const BossRuneIntro({
    required this.session,
    required this.animationKey,
    required this.onSeal,
    this.onComplete,
    super.key,
  });

  static const duration = Duration(milliseconds: 3600);

  final GameSession session;
  final Object animationKey;
  final VoidCallback onSeal;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = shouldAnimateSession(session);
    final controller = useAnimationController(duration: duration);
    final visible = useState(shouldAnimate);

    useEffect(() {
      if (!shouldAnimate) {
        visible.value = false;
        controller.reset();
        return null;
      }

      visible.value = true;
      final sound = Timer(GameAudioEffects.bossRuneIntroSoundDelay, onSeal);
      controller.forward(from: 0).whenCompleteOrCancel(() {
        if (controller.isCompleted) {
          onComplete?.call();
          visible.value = false;
        }
      });

      return () {
        sound.cancel();
      };
    }, [animationKey, shouldAnimate]);

    if (!shouldAnimate || !visible.value) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screen = constraints.biggest;
              final start = Offset(screen.width / 2, screen.height * 0.46);
              final target = _targetCenter(context, screen);
              final startSize = (screen.shortestSide * 0.42)
                  .clamp(172.0, 260.0)
                  .toDouble();
              final targetSize = GamePlayerBadge.medallionDimensionFor(context);
              final presentation = session.bossId.presentation;

              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final value = controller.value;
                  final appear = AppAnimations.interval(
                    value,
                    begin: 0,
                    end: 0.16,
                    curve: AppCurves.entrance,
                  );
                  final shine = AppAnimations.interval(
                    value,
                    begin: 0.1,
                    end: 0.28,
                    curve: AppCurves.entrance,
                  );
                  final returnHome = AppAnimations.interval(
                    value,
                    begin: 0.74,
                    end: 1,
                    curve: AppCurves.standard,
                  );
                  final center =
                      Offset.lerp(start, target, returnHome)! +
                      Offset(0, -math.sin(returnHome * math.pi) * 24);
                  final heldSize = startSize * (0.72 + appear * 0.28);
                  final runeSize =
                      heldSize + (targetSize - heldSize) * returnHome;
                  final opacity = appear.clamp(0.0, 1.0);
                  final pulse = (math.sin(value * math.pi * 2) * 0.5 + 0.5)
                      .clamp(0.0, 1.0);
                  final reveal = (1 - returnHome).clamp(0.0, 1.0);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: BossRuneIntroGlowPainter(
                          center: center,
                          shineProgress: shine,
                          returnProgress: returnHome,
                          opacity: opacity,
                          glowPalette: presentation.glowPalette,
                        ),
                      ),
                      Positioned(
                        left: center.dx - runeSize / 2,
                        top: center.dy - runeSize / 2,
                        width: runeSize,
                        height: runeSize,
                        child: BossRuneRevealVisual(
                          asset: presentation.emblemAsset,
                          shineProgress: shine,
                          opacity: opacity,
                          pulse: pulse,
                          revealProgress: reveal,
                          glowPalette: presentation.glowPalette,
                          shineKey: BossRuneWidgetKeys.introRuneShine,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static bool shouldAnimateSession(GameSession session) {
    return session.hasCpuOpponent &&
        session.result.isOngoing &&
        session.board.emptyCells.length == 9;
  }

  Offset _targetCenter(BuildContext context, Size screen) {
    final compact = AppBreakpoints.isCompact(context);
    final horizontal = compact ? AppSpacing.lg : AppSpacing.xl;
    final top = MediaQuery.paddingOf(context).top + AppSpacing.sm;
    final dimension = GamePlayerBadge.medallionDimensionFor(context);

    return Offset(
      screen.width - horizontal - dimension / 2,
      top + dimension / 2,
    );
  }
}
