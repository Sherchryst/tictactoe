import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';

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
    final pulse = 0.72 + math.sin(shineProgress * math.pi) * 0.28;
    final alpha = (lineOpacity * scaledIntensity * pulse).clamp(0.0, 1.0);

    _drawGlowBand(
      canvas,
      center: center,
      width: lineWidth,
      height: math.max(18, size.height * 0.9),
      color: AppPalette.gold,
      alpha: 0.18 * alpha,
      blur: math.max(5, size.height * 0.24),
    );
    _drawGlowBand(
      canvas,
      center: center,
      width: lineWidth * 0.96,
      height: math.max(14, size.height * 0.68),
      color: AppPalette.goldBright,
      alpha: 0.30 * alpha,
      blur: math.max(3, size.height * 0.14),
    );
    _drawGlowBand(
      canvas,
      center: center,
      width: lineWidth * 0.88,
      height: math.max(10, size.height * 0.46),
      color: AppPalette.ivoryText,
      alpha: 0.16 * alpha,
      blur: math.max(1.5, size.height * 0.06),
    );
  }

  void _drawGlowBand(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required Color color,
    required double alpha,
    required double blur,
  }) {
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final band = _lensPath(rect);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: alpha * 0.66),
          color.withValues(alpha: alpha),
          color.withValues(alpha: alpha * 0.66),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.18, 0.5, 0.82, 1],
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.drawPath(band, paint);
  }

  Path _lensPath(Rect rect) {
    final center = rect.center;
    final left = rect.left;
    final right = rect.right;
    final top = rect.top;
    final bottom = rect.bottom;
    final controlInset = rect.width * 0.22;

    return Path()
      ..moveTo(left, center.dy)
      ..cubicTo(
        left + controlInset,
        top,
        right - controlInset,
        top,
        right,
        center.dy,
      )
      ..cubicTo(
        right - controlInset,
        bottom,
        left + controlInset,
        bottom,
        left,
        center.dy,
      )
      ..close();
  }

  @override
  bool shouldRepaint(_SelectionShinePainter oldDelegate) {
    return reveal != oldDelegate.reveal ||
        shineProgress != oldDelegate.shineProgress ||
        lineOpacity != oldDelegate.lineOpacity ||
        intensity != oldDelegate.intensity;
  }
}
