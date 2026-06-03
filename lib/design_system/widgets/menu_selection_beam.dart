import 'package:flutter/material.dart';

import 'package:tictactoe/design_system/widgets/selection_glow.dart';

class MenuSelectionBeam extends StatelessWidget {
  const MenuSelectionBeam({
    required this.energized,
    this.widthFactor = 0.7,
    this.minWidth = 260,
    this.maxWidth = 480,
    this.height = 26,
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
            lineOpacity: energized ? 0.52 : 0.42,
            hazeOpacity: energized ? 0.74 : 0.62,
            revealFromCenter: true,
            shine: true,
            intensity: energized ? 0.82 : 0.64,
            duration: Duration(milliseconds: energized ? 280 : 420),
          ),
        ),
      ),
    );
  }
}
