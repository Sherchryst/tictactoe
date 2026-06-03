import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_typography.dart';
import 'package:tictactoe/core/design_system/widgets/chrome_corner_flourish.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_category.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_tabs.dart';

class SystemWindow extends StatelessWidget {
  const SystemWindow({
    required this.title,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.child,
    super.key,
  });

  final String title;
  final SystemCategory selectedCategory;
  final ValueChanged<SystemCategory> onCategorySelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2.2, sigmaY: 2.2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppPalette.backgroundDeep.withValues(
              alpha: AppAlphas.medium,
            ),
            border: Border(
              top: BorderSide(
                color: AppPalette.ivoryText.withValues(alpha: AppAlphas.soft),
              ),
              bottom: BorderSide(
                color: AppPalette.ivoryText.withValues(alpha: AppAlphas.subtle),
              ),
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: ChromeCornerFlourish()),
              Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTypography.of(context).sectionTitle(),
                  ),
                  const SizedBox(height: 8),
                  SystemTabs(
                    selectedCategory: selectedCategory,
                    onCategorySelected: onCategorySelected,
                  ),
                  Expanded(child: child),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
