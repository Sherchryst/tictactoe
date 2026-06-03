import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/core/design_system/widgets/app_pressable.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_category.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class SystemTabs extends StatelessWidget {
  const SystemTabs({
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final SystemCategory selectedCategory;
  final ValueChanged<SystemCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 26),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.backgroundDeep.withValues(alpha: AppAlphas.medium),
          border: Border.symmetric(
            horizontal: BorderSide(
              color: AppPalette.ivoryText.withValues(alpha: 0.16),
            ),
          ),
        ),
        child: SizedBox(
          height: compact ? 54 : 58,
          child: Row(
            children: SystemCategory.values.map((category) {
              return Expanded(
                child: _SystemTabButton(
                  category: category,
                  selected: selectedCategory == category,
                  onPressed: () => onCategorySelected(category),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _SystemTabButton extends StatelessWidget {
  const _SystemTabButton({
    required this.category,
    required this.selected,
    required this.onPressed,
  });

  final SystemCategory category;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final copy = AppLocalizations.of(context);
    final compact = AppBreakpoints.isCompact(context);
    final color = selected
        ? AppPalette.goldBright
        : AppPalette.ivoryText.withValues(alpha: AppAlphas.medium);

    return AppPressable(
      onTap: onPressed,
      semanticLabel: category.shortLabel(copy),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (selected)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.86,
                    colors: [
                      AppPalette.gold.withValues(alpha: AppAlphas.muted),
                      const Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                category.shortLabel(copy),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? Theme.of(context).textTheme.labelSmall
                            : Theme.of(context).textTheme.labelMedium)
                        ?.copyWith(
                          color: color,
                          fontFamily: AppPalette.serifFont,
                          fontSize: compact ? 10 : null,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          letterSpacing: 0,
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
