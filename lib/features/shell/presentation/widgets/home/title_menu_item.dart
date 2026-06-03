import 'package:flutter/material.dart';

import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/core/design_system/tokens/app_typography.dart';
import 'package:tictactoe/core/design_system/widgets/app_haptics.dart';
import 'package:tictactoe/core/design_system/widgets/app_pressable.dart';
import 'package:tictactoe/core/design_system/widgets/menu_selection_beam.dart';
import 'package:tictactoe/features/shell/presentation/widgets/home/home_menu_action.dart';

class TitleMenuItem extends StatelessWidget {
  const TitleMenuItem({
    required this.action,
    required this.label,
    required this.selected,
    required this.pressed,
    required this.onPressed,
    required this.itemHeight,
    super.key,
  });

  final HomeMenuAction action;
  final String label;
  final bool selected;
  final bool pressed;
  final VoidCallback onPressed;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final fontSize = (MediaQuery.sizeOf(context).shortestSide * 0.052)
        .clamp(18.0, 21.0)
        .toDouble();

    return AppPressable(
      semanticLabel: label,
      onTap: () {
        AppHaptics.menuSelect();
        onPressed();
      },
      child: SizedBox(
        height: itemHeight,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (selected)
              MenuSelectionBeam(key: ValueKey(action), energized: pressed),
            AnimatedScale(
              duration: AppDurations.short,
              curve: AppCurves.entrance,
              scale: pressed ? 1.045 : (selected ? 1.025 : 1),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: AppDurations.short,
                  curve: AppCurves.entrance,
                  textAlign: TextAlign.center,
                  style:
                      AppTypography.of(
                        context,
                      ).menuItem(selected: selected, fontSize: fontSize) ??
                      const TextStyle(),
                  child: Text(label),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
