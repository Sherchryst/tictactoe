import 'package:flutter/material.dart';

import 'package:tictactoe/core/assets/app_assets.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/design_system/tokens/app_typography.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.message,
    this.icon = AppAssets.runeArc,
    super.key,
  });

  final String message;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: AppAlphas.medium,
              child: Image.asset(
                icon,
                width: 56,
                height: 56,
                fit: BoxFit.contain,
                color: AppPalette.lossRed,
                colorBlendMode: BlendMode.srcATop,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.of(context).helpText(),
            ),
          ],
        ),
      ),
    );
  }
}
