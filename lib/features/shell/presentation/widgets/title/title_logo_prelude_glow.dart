import 'package:flutter/material.dart';

import 'package:tictactoe/features/shell/presentation/rendering/title_logo_prelude_glow_painter.dart';

class TitleLogoPreludeGlow extends StatelessWidget {
  const TitleLogoPreludeGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const TitleLogoPreludeGlowPainter());
  }
}
