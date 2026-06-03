import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/core/design_system/tokens/app_typography.dart';
import 'package:tictactoe/core/design_system/widgets/app_pressable.dart';

class SystemRowChrome extends StatelessWidget {
  const SystemRowChrome({
    required this.selected,
    required this.onTap,
    required this.child,
    super.key,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);

    return AppPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.short,
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 46),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 18,
          vertical: compact ? 9 : 6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? [
                    AppPalette.ivoryText.withValues(alpha: AppAlphas.soft),
                    AppPalette.ivoryText.withValues(alpha: 0.1),
                    AppPalette.ivoryText.withValues(alpha: AppAlphas.whisper),
                  ]
                : [
                    AppPalette.backgroundDeep.withValues(
                      alpha: AppAlphas.muted,
                    ),
                    AppPalette.backgroundDeep.withValues(
                      alpha: AppAlphas.faint,
                    ),
                  ],
          ),
          border: Border(
            top: BorderSide(
              color: AppPalette.ivoryText.withValues(
                alpha: selected ? 0.16 : AppAlphas.whisper,
              ),
            ),
            bottom: BorderSide(
              color: AppPalette.shadow.withValues(alpha: AppAlphas.medium),
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

class SystemRowLabel extends StatelessWidget {
  const SystemRowLabel({
    required this.label,
    required this.selected,
    super.key,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.of(context).rowLabel(selected: selected),
    );
  }
}
