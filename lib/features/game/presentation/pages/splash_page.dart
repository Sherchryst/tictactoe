import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tictactoe/app/di/audio_providers.dart';
import 'package:tictactoe/app/router/app_routes.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_curves.dart';
import 'package:tictactoe/design_system/tokens/app_durations.dart';
import 'package:tictactoe/design_system/widgets/ambient_motes.dart';
import 'package:tictactoe/design_system/widgets/sigil_backdrop.dart';
import 'package:tictactoe/features/game/domain/entities/music_track.dart';

class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: AppDurations.splashScreen,
    );
    final opened = useRef(false);

    void openTitle() {
      if (opened.value || !context.mounted) {
        return;
      }
      opened.value = true;
      context.go(AppRoutes.titleLocation);
    }

    useEffect(() {
      unawaited(ref.read(audioControllerProvider).playTrack(MusicTrack.menu));
      unawaited(controller.forward());
      Future<void>.delayed(controller.duration!).then((_) => openTitle());

      return null;
    }, const []);

    final screen = MediaQuery.sizeOf(context);
    final sigilSize = (screen.shortestSide * 0.74).clamp(280.0, 390.0);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: openTitle,
        child: ColoredBox(
          color: AppPalette.backgroundDeep,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final value = controller.value;
              final sigil = AppCurves.entrance.transform(
                (value / 0.7).clamp(0.0, 1.0),
              );
              final fadeOut = AppCurves.exit.transform(
                ((value - 0.82) / 0.18).clamp(0.0, 1.0),
              );
              final opacity = (1 - fadeOut).clamp(0.0, 1.0);
              final pulse = math.sin(value * math.pi).clamp(0.0, 1.0);

              return Opacity(
                opacity: opacity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AmbientMotes(
                      controller: controller,
                      flow: AmbientMoteFlow.twinkle,
                      maxAlpha: 0.19,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.04),
                          radius: 0.78,
                          colors: [
                            AppPalette.gold.withValues(
                              alpha: 0.1 + pulse * 0.12,
                            ),
                            AppPalette.goldDim.withValues(alpha: 0.04),
                            AppPalette.backgroundDeep,
                          ],
                          stops: const [0, 0.42, 1],
                        ),
                      ),
                    ),
                    Center(
                      child: Transform.translate(
                        offset: Offset(0, 18 * (1 - sigil)),
                        child: Transform.scale(
                          scale: 0.9 + sigil * 0.1 + pulse * 0.016,
                          child: Opacity(
                            opacity: sigil,
                            child: SigilBackdrop(
                              width: sigilSize,
                              height: sigilSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
