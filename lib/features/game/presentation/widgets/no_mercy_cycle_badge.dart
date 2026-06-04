import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/core/design_system/widgets/glyph_safe_text.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class NoMercyCycleBadge extends StatelessWidget {
  const NoMercyCycleBadge({required this.cycle, super.key});

  final int cycle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.backgroundDeep.withValues(alpha: AppAlphas.opaque),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppPalette.goldBright.withValues(alpha: AppAlphas.medium),
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.gold.withValues(alpha: AppAlphas.soft),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppPalette.shadow.withValues(alpha: AppAlphas.strong),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: GlyphSafeText(
          AppLocalizations.of(context).noMercyCycleBadge(cycle),
          maxLines: 1,
          overflow: TextOverflow.visible,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppPalette.goldBright.withValues(alpha: AppAlphas.opaque),
            fontFamily: AppPalette.titleFont,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            shadows: [
              Shadow(
                color: AppPalette.gold.withValues(alpha: AppAlphas.medium),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
