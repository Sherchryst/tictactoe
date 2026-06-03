import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:tictactoe/core/assets/app_assets.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_curves.dart';
import 'package:tictactoe/design_system/tokens/app_durations.dart';

class SelectionGlow extends StatelessWidget {
  const SelectionGlow({
    this.lineOpacity = 0.46,
    this.hazeOpacity = 0.75,
    this.revealFromCenter = false,
    this.shine = false,
    this.intensity = 1,
    this.duration = AppDurations.selectionGlow,
    super.key,
  });

  final double lineOpacity;
  final double hazeOpacity;
  final bool revealFromCenter;
  final bool shine;
  final double intensity;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: duration,
        curve: revealFromCenter ? AppCurves.entrance : AppCurves.shimmer,
        builder: (context, value, child) {
          final reveal = revealFromCenter
              ? AppCurves.entrance.transform(value)
              : 1.0;
          final pulse = revealFromCenter
              ? 0.62 + reveal * 0.38
              : 0.25 + math.sin(value * math.pi) * 0.6;
          final assetOpacity =
              pulse * (0.52 + hazeOpacity * 0.34 + lineOpacity * 0.18);

          return Opacity(
            opacity: (assetOpacity * intensity).clamp(0.0, 1.0),
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                ClipRect(
                  clipper: _CenterRevealClipper(reveal),
                  child: SvgPicture.asset(
                    AppAssets.titleSelectionGlow,
                    fit: BoxFit.fill,
                    excludeFromSemantics: true,
                  ),
                ),
                if (shine)
                  CustomPaint(
                    painter: _SelectionShinePainter(
                      reveal: reveal,
                      shineProgress: value,
                      lineOpacity: lineOpacity,
                      intensity: intensity,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CenterRevealClipper extends CustomClipper<Rect> {
  const _CenterRevealClipper(this.reveal);

  final double reveal;

  @override
  Rect getClip(Size size) {
    return Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * reveal.clamp(0.0, 1.0),
      height: size.height,
    );
  }

  @override
  bool shouldReclip(_CenterRevealClipper oldClipper) {
    return reveal != oldClipper.reveal;
  }
}

class _SelectionShinePainter extends CustomPainter {
  const _SelectionShinePainter({
    required this.reveal,
    required this.shineProgress,
    required this.lineOpacity,
    required this.intensity,
  });

  final double reveal;
  final double shineProgress;
  final double lineOpacity;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final clampedReveal = reveal.clamp(0.0, 1.0);
    if (clampedReveal == 0) {
      return;
    }

    final center = size.center(Offset.zero);
    final scaledIntensity = intensity.clamp(0.0, 1.4);
    final lineWidth = size.width * 0.92 * clampedReveal;
    final shineCurve = AppCurves.standard.transform(shineProgress);
    final fade = math.sin(shineProgress * math.pi).clamp(0.0, 1.0);
    final distance = lineWidth * 0.5 * shineCurve;
    final glintLength = size.width * 0.055;
    final glint = Paint()
      ..color = AppPalette.ivoryText.withValues(
        alpha: (0.9 * lineOpacity * fade * scaledIntensity).clamp(0.0, 1.0),
      )
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.8, size.height * 0.11)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.2);

    final core = Paint()
      ..color = AppPalette.goldBright.withValues(
        alpha: (0.28 * (1 - shineCurve) * scaledIntensity).clamp(0.0, 1.0),
      )
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.4, size.height * 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawLine(
      Offset(center.dx - lineWidth * 0.32, center.dy),
      Offset(center.dx + lineWidth * 0.32, center.dy),
      core,
    );

    for (final direction in const [-1, 1]) {
      final dx = center.dx + distance * direction;
      canvas.drawLine(
        Offset(dx - glintLength * direction, center.dy),
        Offset(dx + glintLength * direction, center.dy),
        glint,
      );
    }
  }

  @override
  bool shouldRepaint(_SelectionShinePainter oldDelegate) {
    return reveal != oldDelegate.reveal ||
        shineProgress != oldDelegate.shineProgress ||
        lineOpacity != oldDelegate.lineOpacity ||
        intensity != oldDelegate.intensity;
  }
}
