import 'package:flutter/painting.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_alphas.dart';

final class AppShadows {
  const AppShadows._();

  static List<BoxShadow> board() {
    return [
      BoxShadow(
        color: AppPalette.shadow.withValues(alpha: AppAlphas.strong),
        blurRadius: 38,
        offset: const Offset(0, 18),
      ),
      BoxShadow(
        color: AppPalette.gold.withValues(alpha: AppAlphas.subtle),
        blurRadius: 28,
      ),
    ];
  }

  static List<BoxShadow> dialog() {
    return [
      BoxShadow(
        color: AppPalette.shadow.withValues(alpha: 0.72),
        blurRadius: 34,
        offset: const Offset(0, 18),
      ),
      BoxShadow(
        color: AppPalette.gold.withValues(alpha: AppAlphas.subtle),
        blurRadius: 24,
      ),
    ];
  }

  static List<Shadow> ivoryGlow({double alpha = AppAlphas.medium}) {
    return [
      Shadow(color: AppPalette.gold.withValues(alpha: alpha), blurRadius: 18),
    ];
  }

  static List<Shadow> goldDimGlow({double blurRadius = 14}) {
    return [Shadow(color: AppPalette.goldDim, blurRadius: blurRadius)];
  }
}
