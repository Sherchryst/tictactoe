import 'package:flutter/material.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/design_system/tokens/app_typography.dart';
import 'package:tictactoe/design_system/widgets/app_pressable.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';

class SystemFooter extends StatelessWidget {
  const SystemFooter({required this.helpText, required this.onBack, super.key});

  final String helpText;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 24,
        6,
        compact ? 14 : 24,
        compact ? 10 : 16,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Row(
          children: [
            Expanded(
              child: Text(
                helpText,
                maxLines: compact ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.of(context).helpText(),
              ),
            ),
            const SizedBox(width: 12),
            _FooterBackButton(onPressed: onBack),
          ],
        ),
      ),
    );
  }
}

class _FooterBackButton extends StatelessWidget {
  const _FooterBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final copy = GameCopy.of(context);

    return AppPressable(
      onTap: onPressed,
      semanticLabel: copy.backTooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.backgroundDeep.withValues(alpha: AppAlphas.medium),
          border: Border.all(
            color: AppPalette.ivoryText.withValues(alpha: 0.2),
          ),
        ),
        child: SizedBox(
          height: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppPalette.ivoryText.withValues(
                    alpha: AppAlphas.dominant,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  copy.backTooltip,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPalette.ivoryText.withValues(alpha: 0.82),
                    fontFamily: AppPalette.serifFont,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
