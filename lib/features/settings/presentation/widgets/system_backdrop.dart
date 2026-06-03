import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/design_system/tokens/app_gradients.dart';
import 'package:tictactoe/core/design_system/widgets/sigil_backdrop.dart';

class SystemBackdrop extends StatelessWidget {
  const SystemBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);

    return ColoredBox(
      color: AppPalette.backgroundDeep,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: screen.height * 0.05,
            left: -screen.width * 0.42,
            right: -screen.width * 0.42,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                AppAssets.wordmark,
                height: screen.height * 0.2,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          const Positioned.fill(
            child: Opacity(opacity: 0.16, child: SigilBackdrop()),
          ),
          DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.systemBackdrop()),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.12),
                radius: 0.86,
                colors: [
                  AppPalette.gold.withValues(alpha: AppAlphas.subtle),
                  const Color(0x00000000),
                ],
                stops: const [0, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
