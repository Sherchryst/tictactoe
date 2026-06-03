import 'package:flutter/material.dart';

import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_alphas.dart';

class ChromeCornerFlourish extends StatelessWidget {
  const ChromeCornerFlourish({this.extent = 26, super.key});

  final double extent;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ChromeCornerFlourishPainter(extent: extent),
        size: Size.infinite,
      ),
    );
  }
}

class _ChromeCornerFlourishPainter extends CustomPainter {
  const _ChromeCornerFlourishPainter({required this.extent});

  final double extent;

  @override
  void paint(Canvas canvas, Size size) {
    final arm = extent.clamp(12.0, 40.0);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4;

    void corner(Offset origin, {required bool flipX, required bool flipY}) {
      final dx = flipX ? -1.0 : 1.0;
      final dy = flipY ? -1.0 : 1.0;
      final path = Path()
        ..moveTo(origin.dx, origin.dy + dy * arm * 0.42)
        ..lineTo(origin.dx, origin.dy)
        ..lineTo(origin.dx + dx * arm * 0.42, origin.dy);

      stroke.shader = LinearGradient(
        begin: Alignment.center,
        end: Alignment(flipX ? 1 : -1, flipY ? 1 : -1),
        colors: [
          AppPalette.goldBright.withValues(alpha: AppAlphas.medium),
          AppPalette.gold.withValues(alpha: AppAlphas.subtle),
          Colors.transparent,
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: origin, radius: arm));

      canvas.drawPath(path, stroke);
    }

    corner(Offset.zero, flipX: false, flipY: false);
    corner(Offset(size.width, 0), flipX: true, flipY: false);
    corner(Offset(0, size.height), flipX: false, flipY: true);
    corner(Offset(size.width, size.height), flipX: true, flipY: true);
  }

  @override
  bool shouldRepaint(covariant _ChromeCornerFlourishPainter oldDelegate) {
    return oldDelegate.extent != extent;
  }
}
