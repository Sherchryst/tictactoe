import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/design_system/tokens/app_durations.dart';
import 'package:tictactoe/design_system/tokens/app_gradients.dart';
import 'package:tictactoe/design_system/widgets/ambient_motes.dart';
import 'package:tictactoe/design_system/widgets/fog_veil.dart';
import 'package:tictactoe/design_system/widgets/grace_glow.dart';

class GameSceneBackdrop extends HookWidget {
  const GameSceneBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final embers = useAnimationController(
      duration: AppDurations.sceneEmbersLoop,
    );
    final breath = useAnimationController(duration: AppDurations.graceBreath);
    final fog = useAnimationController(duration: AppDurations.fogDrift);

    useEffect(() {
      embers.repeat();
      breath.repeat(reverse: true);
      fog.repeat();
      return null;
    }, const []);

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.backgroundDeep,
          gradient: AppGradients.sceneVerticalDim(),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GraceGlow(
              animation: breath,
              alignment: const Alignment(0, 1.08),
              radius: 1.05,
              intensity: 0.9,
            ),
            DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.goldHalo()),
            ),
            FogVeil(
              animation: fog,
              intensity: 0.55,
              verticalBias: 0.86,
              spread: 0.5,
            ),
            AmbientMotes(
              controller: embers,
              count: 34,
              maxAlpha: AppAlphas.soft,
            ),
            DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.sideVignette()),
            ),
            DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.topShade()),
            ),
          ],
        ),
      ),
    );
  }
}
