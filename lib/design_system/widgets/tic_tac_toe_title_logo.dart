import 'package:flutter/material.dart';

import 'package:tictactoe/design_system/theme/app_palette.dart';

class TicTacToeTitleLogo extends StatelessWidget {
  const TicTacToeTitleLogo({this.fontSize, this.opacity = 1, super.key});

  final double? fontSize;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final resolvedFontSize =
        fontSize ?? (MediaQuery.sizeOf(context).shortestSide * 0.18);

    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth = MediaQuery.sizeOf(context).width - 40;
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : fallbackWidth.clamp(0, double.infinity).toDouble();
        final fittedFontSize = _fitFontSize(
          text: 'Tic Tac Toe',
          maxWidth: width,
          fontSize: resolvedFontSize,
        );
        final height = fittedFontSize * 1.36;

        return Semantics(
          label: 'Tic Tac Toe',
          child: Opacity(
            opacity: opacity,
            child: RepaintBoundary(
              child: SizedBox(
                width: width,
                height: height,
                child: ClipRect(
                  child: CustomPaint(
                    painter: _TitleLogoPainter(fontSize: fittedFontSize),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static double _fitFontSize({
    required String text,
    required double maxWidth,
    required double fontSize,
  }) {
    if (maxWidth <= 0) {
      return fontSize;
    }

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: _textStyle(fontSize: fontSize),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout();
    final availableWidth = maxWidth * 0.98;

    if (painter.width <= availableWidth) {
      return fontSize;
    }

    return fontSize * (availableWidth / painter.width);
  }
}

class _TitleLogoPainter extends CustomPainter {
  const _TitleLogoPainter({required this.fontSize});

  final double fontSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final glowPaint = Paint()
      ..color = AppPalette.shadow.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.08),
        width: size.width * 0.94,
        height: size.height * 0.34,
      ),
      glowPaint,
    );

    final textOffset = _textOffset(size);
    final textRect = Rect.fromLTWH(
      textOffset.dx,
      textOffset.dy,
      size.width - textOffset.dx * 2,
      fontSize,
    );
    final textPainter = _textPainter(
      foreground: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffffefc6),
            AppPalette.goldBright,
            AppPalette.titleGold,
            Color(0xff6e461c),
          ],
          stops: [0, 0.28, 0.64, 1],
        ).createShader(textRect),
    )..layout(maxWidth: size.width);

    textPainter.paint(canvas, textOffset);
  }

  Offset _textOffset(Size size) {
    final textPainter = _textPainter()..layout(maxWidth: size.width);

    return Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
  }

  TextPainter _textPainter({Paint? foreground}) {
    return TextPainter(
      text: TextSpan(
        text: 'Tic Tac Toe',
        style: _textStyle(fontSize: fontSize, foreground: foreground),
      ),
      maxLines: 1,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    );
  }

  @override
  bool shouldRepaint(_TitleLogoPainter oldDelegate) {
    return oldDelegate.fontSize != fontSize;
  }
}

TextStyle _textStyle({required double fontSize, Paint? foreground}) {
  return TextStyle(
    color: foreground == null ? AppPalette.goldBright : null,
    fontFamily: AppPalette.titleFont,
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 0,
    foreground: foreground,
    shadows: const [Shadow(color: AppPalette.goldDim, blurRadius: 16)],
  );
}
