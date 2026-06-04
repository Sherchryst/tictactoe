import 'package:flutter/material.dart';

import 'package:tictactoe/core/design_system/widgets/selection_glow.dart';

class MenuSelectionBeam extends StatelessWidget {
  const MenuSelectionBeam({
    required this.energized,
    this.widthFactor = 0.78,
    this.minWidth = 300,
    this.maxWidth = 560,
    this.height = 34,
    super.key,
  });

  final bool energized;
  final double widthFactor;
  final double minWidth;
  final double maxWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final beamWidth = (MediaQuery.sizeOf(context).width * widthFactor)
        .clamp(minWidth, maxWidth)
        .toDouble();

    return IgnorePointer(
      child: OverflowBox(
        minWidth: beamWidth,
        maxWidth: beamWidth,
        minHeight: height,
        maxHeight: height,
        child: SizedBox(
          width: beamWidth,
          height: height,
          child: SelectionGlow(
            key: ValueKey(energized),
            lineOpacity: energized ? 0.58 : 0.46,
            hazeOpacity: energized ? 0.78 : 0.62,
            revealFromCenter: true,
            intensity: energized ? 0.78 : 0.62,
            duration: Duration(milliseconds: energized ? 280 : 420),
          ),
        ),
      ),
    );
  }
}
