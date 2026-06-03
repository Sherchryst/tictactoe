import 'package:flutter/material.dart';

import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';

class AppPressable extends StatelessWidget {
  const AppPressable({
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.pressed = false,
    this.pressedScale = 1,
    this.idleScale = 1,
    this.duration = AppDurations.micro,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool pressed;
  final double pressedScale;
  final double idleScale;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final detector = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedScale(
        duration: duration,
        curve: AppCurves.entrance,
        scale: pressed ? pressedScale : idleScale,
        child: child,
      ),
    );

    if (semanticLabel == null) {
      return detector;
    }

    return Semantics(button: true, label: semanticLabel, child: detector);
  }
}
