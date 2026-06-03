import 'package:flutter/painting.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_alphas.dart';

final class AppGradients {
  const AppGradients._();

  static RadialGradient boardSurface() {
    return RadialGradient(
      center: const Alignment(0, -0.18),
      radius: 0.92,
      colors: [
        AppPalette.surfaceRaised.withValues(alpha: AppAlphas.dominant),
        AppPalette.surface.withValues(alpha: AppAlphas.opaque),
        AppPalette.backgroundDeep,
      ],
      stops: const [0, 0.7, 1],
    );
  }

  static LinearGradient sceneVerticalDim() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppPalette.backgroundDeep,
        AppPalette.surface.withValues(alpha: AppAlphas.dominant),
        AppPalette.backgroundDeep,
      ],
      stops: const [0, 0.48, 1],
    );
  }

  static RadialGradient goldHalo({double radius = 0.78}) {
    return RadialGradient(
      center: const Alignment(0, -0.06),
      radius: radius,
      colors: [
        AppPalette.gold.withValues(alpha: 0.13),
        const Color(0x00000000),
      ],
      stops: const [0, 1],
    );
  }

  static LinearGradient sideVignette() {
    return LinearGradient(
      colors: [
        AppPalette.backgroundDeep.withValues(alpha: AppAlphas.strong),
        const Color(0x00000000),
        AppPalette.backgroundDeep.withValues(alpha: AppAlphas.strong),
      ],
      stops: const [0, 0.5, 1],
    );
  }

  static LinearGradient gilded() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppPalette.goldBright, AppPalette.gold, AppPalette.goldDim],
      stops: [0, 0.55, 1],
    );
  }

  static LinearGradient topShade() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.center,
      colors: [
        AppPalette.backgroundDeep.withValues(alpha: AppAlphas.strong),
        const Color(0x00000000),
      ],
    );
  }

  static LinearGradient systemBackdrop() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppPalette.chromeOlive.withValues(alpha: AppAlphas.strong),
        AppPalette.background.withValues(alpha: 0.93),
        AppPalette.chromeUmber,
      ],
      stops: const [0, 0.55, 1],
    );
  }
}
