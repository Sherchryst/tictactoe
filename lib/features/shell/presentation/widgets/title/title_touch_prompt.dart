import 'package:flutter/material.dart';

import 'package:tictactoe/core/design_system/tokens/app_typography.dart';
import 'package:tictactoe/core/design_system/widgets/menu_selection_beam.dart';

class TitleTouchPrompt extends StatelessWidget {
  const TitleTouchPrompt({
    required this.label,
    required this.pressAnimation,
    super.key,
  });

  final String label;
  final Animation<double> pressAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pressAnimation,
      builder: (context, child) {
        final press = Curves.easeOutCubic.transform(pressAnimation.value);

        return Center(
          child: SizedBox(
            height: 35,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (pressAnimation.value > 0)
                  const MenuSelectionBeam(energized: true),
                Transform.scale(
                  scale: 1.025 + press * 0.02,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.of(context).prompt(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
