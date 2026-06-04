import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/presentation/utils/rendering/board_effect_painters.dart';
import 'package:tictactoe/features/game/presentation/utils/rendering/winning_beam_painter.dart';

class GameBoardImpactFlash extends StatelessWidget {
  const GameBoardImpactFlash({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppDurations.boardMarkReveal,
          curve: AppCurves.emphasized,
          builder: (context, value, child) {
            return Opacity(
              opacity: (1 - value).clamp(0.0, 0.9),
              child: Transform.scale(scale: 0.78 + value * 0.52, child: child),
            );
          },
          child: SizedBox.square(
            dimension: 118,
            child: CustomPaint(
              isComplex: true,
              willChange: true,
              painter: ImpactFlashPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

class GameBoardSlashEffect extends StatelessWidget {
  const GameBoardSlashEffect({
    required this.isGold,
    required this.angle,
    super.key,
  });

  final bool isGold;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppDurations.medium,
          curve: AppCurves.entrance,
          builder: (context, value, child) {
            final opacity = value < 0.42 ? value / 0.42 : (1 - value) / 0.58;

            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.rotate(
                angle: angle,
                child: Transform.scale(
                  scale: 0.78 + value * 0.34,
                  child: child,
                ),
              ),
            );
          },
          child: SizedBox.square(
            dimension: 142,
            child: CustomPaint(
              isComplex: true,
              willChange: true,
              painter: SlashPainter(isGold: isGold),
            ),
          ),
        ),
      ),
    );
  }
}

class GameBoardParticleRing extends StatelessWidget {
  const GameBoardParticleRing({required this.isGold, super.key});

  final bool isGold;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppDurations.boardParticleRing,
          curve: AppCurves.entrance,
          builder: (context, value, child) {
            return Opacity(
              opacity: (1 - value).clamp(0.0, 0.72),
              child: SizedBox.square(
                dimension: 116,
                child: CustomPaint(
                  isComplex: true,
                  willChange: true,
                  painter: ParticleRingPainter(progress: value, isGold: isGold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GameBoardWinningBeam extends StatelessWidget {
  const GameBoardWinningBeam({
    required this.winningCells,
    required this.winner,
    super.key,
  });

  final List<int> winningCells;
  final Mark winner;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;

            return TweenAnimationBuilder<double>(
              key: ValueKey('${winner.name}:${winningCells.join('-')}'),
              tween: Tween(begin: 0, end: 1),
              duration: AppDurations.boardWinBeam,
              builder: (context, value, child) {
                return RepaintBoundary(
                  child: CustomPaint(
                    size: size,
                    isComplex: true,
                    willChange: true,
                    painter: WinningBeamPainter(
                      winningCells: winningCells,
                      winner: winner,
                      progress: value,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class GameBoardDrawFog extends StatelessWidget {
  const GameBoardDrawFog({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: IgnorePointer(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: AppDurations.boardDrawFog,
            curve: AppCurves.entrance,
            builder: (context, value, child) {
              return Opacity(
                opacity: (1 - value).clamp(0.0, 0.46),
                child: Transform.translate(
                  offset: Offset(0, -18 * value),
                  child: child,
                ),
              );
            },
            child: CustomPaint(
              isComplex: true,
              willChange: true,
              painter: DrawFogPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

class GameBoardDrawShake extends HookWidget {
  const GameBoardDrawShake({
    required this.enabled,
    required this.child,
    super.key,
  });

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: AppDurations.boardDrawShake,
    );
    final offset = useMemoized(() {
      return TweenSequence<double>([
        TweenSequenceItem(tween: ConstantTween(-2), weight: 1),
        TweenSequenceItem(tween: ConstantTween(2), weight: 1),
        TweenSequenceItem(tween: ConstantTween(-1), weight: 1),
        TweenSequenceItem(tween: ConstantTween(1), weight: 1),
        TweenSequenceItem(tween: ConstantTween(0), weight: 1),
      ]).animate(controller);
    }, [controller]);
    final hasBuilt = useRef(false);

    useEffect(() {
      if (hasBuilt.value && enabled) {
        unawaited(controller.forward(from: 0));
      }
      hasBuilt.value = true;

      return null;
    }, [enabled]);

    return AnimatedBuilder(
      animation: offset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(offset.value, 0),
          child: child,
        );
      },
      child: child,
    );
  }
}
