import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tictactoe/core/design_system/widgets/selection_glow.dart';
import 'package:tictactoe/features/shell/presentation/rendering/loading_beam_painter.dart';

class LoadingBeam extends StatelessWidget {
  const LoadingBeam({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width * 0.7)
        .clamp(270.0, 520.0)
        .toDouble();
    final easedProgress = Curves.easeInOutCubic.transform(
      progress.clamp(0.0, 1.0),
    );

    return SizedBox(
      width: width,
      height: 42,
      child: _BeamEdgeFade(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Opacity(
              opacity: 0.28,
              child: SelectionGlow(
                lineOpacity: 0.32,
                hazeOpacity: 0.36,
                revealFromCenter: true,
                intensity: 0.52,
                duration: Duration(milliseconds: 700),
              ),
            ),
            _SoftProgressReveal(
              progress: easedProgress,
              child: const SelectionGlow(
                lineOpacity: 0.58,
                hazeOpacity: 0.8,
                shine: true,
                intensity: 0.95,
                duration: Duration(seconds: 5),
              ),
            ),
            CustomPaint(
              size: Size(width, 42),
              painter: LoadingBeamPainter(easedProgress),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeamEdgeFade extends StatelessWidget {
  const _BeamEdgeFade({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [0, 0.12, 0.88, 1],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

class _SoftProgressReveal extends StatelessWidget {
  const _SoftProgressReveal({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    if (clampedProgress == 0) {
      return const SizedBox.shrink();
    }

    final halfWidth = clampedProgress * 0.5;
    final softEdge = math.min(0.12, clampedProgress * 0.48);
    final left = 0.5 - halfWidth;
    final right = 0.5 + halfWidth;
    final leftFadeEnd = math.min(left + softEdge, 0.5);
    final rightFadeStart = math.max(right - softEdge, 0.5);

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: const [
            Colors.transparent,
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
            Colors.transparent,
          ],
          stops: [0, left, leftFadeEnd, rightFadeStart, right, 1],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
