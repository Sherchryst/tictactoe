import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/widgets/selection_glow.dart';

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
              painter: _LoadingBeamPainter(easedProgress),
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

class _LoadingBeamPainter extends CustomPainter {
  const _LoadingBeamPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    if (clampedProgress == 0) {
      return;
    }

    final center = size.center(Offset.zero);
    final lineWidth = size.width * clampedProgress;
    final lineRect = Rect.fromCenter(
      center: center,
      width: lineWidth,
      height: size.height,
    );
    final haloPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, AppPalette.goldBright, Colors.transparent],
      ).createShader(lineRect)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(6, size.height * 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    final corePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          AppPalette.gold,
          AppPalette.ivoryText,
          AppPalette.gold,
          Colors.transparent,
        ],
      ).createShader(lineRect)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.8, size.height * 0.08);

    canvas.drawLine(
      Offset(center.dx - lineWidth * 0.5, center.dy),
      Offset(center.dx + lineWidth * 0.5, center.dy),
      haloPaint,
    );
    canvas.drawLine(
      Offset(center.dx - lineWidth * 0.48, center.dy),
      Offset(center.dx + lineWidth * 0.48, center.dy),
      corePaint,
    );
  }

  @override
  bool shouldRepaint(_LoadingBeamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
