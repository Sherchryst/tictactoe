import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/core/design_system/widgets/app_pressable.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);
    final dimension = compact ? 42.0 : 46.0;

    final button = AppPressable(
      onTap: onPressed,
      semanticLabel: semanticLabel ?? tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.backgroundDeep.withValues(alpha: AppAlphas.medium),
          border: Border.all(
            color: AppPalette.ivoryText.withValues(alpha: 0.2),
          ),
        ),
        child: SizedBox.square(
          dimension: dimension,
          child: Icon(
            icon,
            color: AppPalette.ivoryText.withValues(alpha: AppAlphas.dominant),
            size: compact ? 21 : 23,
          ),
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }

    return Tooltip(message: tooltip!, child: button);
  }
}
