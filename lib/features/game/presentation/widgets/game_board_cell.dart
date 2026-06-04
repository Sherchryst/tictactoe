import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/core/design_system/widgets/app_haptics.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/entities/participant.dart';
import 'package:tictactoe/features/game/presentation/utils/bosses/boss_presentation.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_board_effects.dart';

class GameBoardCell extends HookWidget {
  const GameBoardCell({
    required this.mark,
    required this.session,
    required this.highlighted,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final Mark? mark;
  final GameSession session;
  final bool highlighted;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final pressed = useState(false);

    void setPressed(bool value) {
      void applyPressed() {
        if (!context.mounted || pressed.value == value) {
          return;
        }

        pressed.value = value;
      }

      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) => applyPressed());
      } else {
        applyPressed();
      }
    }

    return Semantics(
      button: enabled,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setPressed(true) : null,
          onTapCancel: enabled ? () => setPressed(false) : null,
          onTapUp: enabled
              ? (_) {
                  setPressed(false);
                  unawaited(AppHaptics.markPlaced());
                  onPressed();
                }
              : null,
          child: AnimatedScale(
            duration: AppDurations.micro,
            curve: AppCurves.entrance,
            scale: pressed.value ? 0.96 : 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (highlighted)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppPalette.gold.withValues(alpha: AppAlphas.soft),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                RepaintBoundary(
                  child: _Mark(mark: mark, session: session),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkHalo extends StatelessWidget {
  const _MarkHalo();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppPalette.goldBright.withValues(alpha: AppAlphas.medium),
            AppPalette.gold.withValues(alpha: AppAlphas.faint),
            const Color(0x00000000),
          ],
          stops: const [0, 0.45, 1],
        ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.mark, required this.session});

  final Mark? mark;
  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final resolvedMark = mark;

    if (resolvedMark == null) {
      return const SizedBox.shrink();
    }

    final participant = session.participantFor(resolvedMark);
    final asset = switch (participant) {
      CpuParticipant(:final bossId) => bossId.presentation.aliveAsset,
      HumanParticipant() when session.isNoMercy => AppAssets.runeArc,
      HumanParticipant() =>
        resolvedMark == Mark.x ? AppAssets.markX : AppAssets.markO,
    };
    final isGold =
        session.isNoMercy ||
        participant.kind == ParticipantKind.cpu ||
        resolvedMark == Mark.o;
    final slashAngle = resolvedMark == Mark.x ? -math.pi / 12 : math.pi / 12;

    return TweenAnimationBuilder<double>(
      key: ValueKey(asset),
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.boardMarkReveal,
      curve: AppCurves.entrance,
      builder: (context, value, child) {
        final markScale = value < 0.72
            ? 0.72 + value / 0.72 * 0.32
            : 1.04 - (value - 0.72) / 0.28 * 0.04;

        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -8 * (1 - value)),
            child: Transform.scale(scale: markScale, child: child),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          const FractionallySizedBox(
            widthFactor: 0.92,
            heightFactor: 0.92,
            child: _MarkHalo(),
          ),
          const GameBoardImpactFlash(),
          GameBoardSlashEffect(isGold: isGold, angle: slashAngle),
          GameBoardParticleRing(isGold: isGold),
          FractionallySizedBox(
            widthFactor: asset == AppAssets.markX ? 0.58 : 0.62,
            heightFactor: asset == AppAssets.markX ? 0.58 : 0.62,
            child: Image.asset(asset, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
