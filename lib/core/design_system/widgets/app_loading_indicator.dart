import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';

class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({this.size = 32, this.showSigil = true, super.key});

  final double size;
  final bool showSigil;

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.epic,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pulse =
              0.65 + (math.sin(_controller.value * math.pi * 2) + 1) / 2 * 0.35;

          return Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              if (widget.showSigil)
                Opacity(
                  opacity: AppAlphas.subtle * pulse,
                  child: Image.asset(
                    AppAssets.sigil,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    excludeFromSemantics: true,
                  ),
                ),
              Transform.rotate(
                angle: _controller.value * math.pi * 2,
                child: CustomPaint(
                  painter: _GoldArcPainter(
                    progress: AppCurves.shimmer.transform(_controller.value),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GoldArcPainter extends CustomPainter {
  const _GoldArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 1.5;

    final track = Paint()
      ..color = AppPalette.goldDim.withValues(alpha: AppAlphas.muted)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;
    final glow = Paint()
      ..color = AppPalette.goldBright.withValues(alpha: AppAlphas.medium)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
    final arc = Paint()
      ..color = AppPalette.goldBright.withValues(alpha: AppAlphas.dominant)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;

    canvas.drawCircle(center, radius, track);

    final sweep = math.pi * (0.6 + 0.5 * progress);
    const start = -math.pi / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, start, sweep, false, glow);
    canvas.drawArc(rect, start, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant _GoldArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
