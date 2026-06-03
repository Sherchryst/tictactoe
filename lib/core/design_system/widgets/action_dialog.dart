import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/core/design_system/tokens/app_typography.dart';
import 'package:tictactoe/core/design_system/widgets/app_haptics.dart';
import 'package:tictactoe/core/design_system/widgets/chrome_corner_flourish.dart';
import 'package:tictactoe/core/design_system/widgets/selection_glow.dart';

Future<T?> showActionDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required String barrierLabel,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: AppPalette.backgroundDeep.withValues(alpha: 0.76),
    transitionDuration: AppDurations.dialogTransition,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppCurves.entrance,
        reverseCurve: AppCurves.exit,
      );

      return FadeTransition(
        opacity: curved,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - curved.value)),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

class ActionDialog extends StatelessWidget {
  const ActionDialog({
    required this.title,
    required this.message,
    required this.actions,
    this.leadingArt,
    this.content,
    this.onActionFeedback,
    super.key,
  });

  final String title;
  final String message;
  final List<ActionDialogButton> actions;
  final Widget? leadingArt;
  final Widget? content;
  final VoidCallback? onActionFeedback;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 22 : 32,
        vertical: 24,
      ),
      backgroundColor: Colors.transparent,
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.dialogMaxWidth,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppPalette.backgroundDeep.withValues(alpha: 0.78),
                border: Border(
                  top: BorderSide(
                    color: AppPalette.goldBright.withValues(alpha: 0.36),
                  ),
                  bottom: BorderSide(
                    color: AppPalette.gold.withValues(alpha: 0.3),
                  ),
                  left: BorderSide(
                    color: AppPalette.goldDim.withValues(alpha: 0.18),
                  ),
                  right: BorderSide(
                    color: AppPalette.goldDim.withValues(alpha: 0.18),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppPalette.shadow.withValues(alpha: 0.72),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: AppPalette.gold.withValues(alpha: 0.12),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned.fill(child: ChromeCornerFlourish()),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.54),
                          radius: 0.94,
                          colors: [
                            AppPalette.gold.withValues(alpha: 0.14),
                            AppPalette.surface.withValues(alpha: 0.34),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.58, 1],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 20 : 26,
                      compact ? 22 : 26,
                      compact ? 20 : 26,
                      compact ? 18 : 22,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (leadingArt != null) ...[
                          Center(child: leadingArt),
                          SizedBox(height: compact ? 10 : 14),
                        ],
                        SizedBox(
                          height: compact ? 54 : 62,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Positioned(
                                left: 0,
                                right: 0,
                                bottom: 4,
                                height: 30,
                                child: SelectionGlow(
                                  lineOpacity: 0.2,
                                  hazeOpacity: 0.28,
                                  revealFromCenter: true,
                                  shine: true,
                                  intensity: 0.54,
                                  duration: AppDurations.dialogTitleGlow,
                                ),
                              ),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontFamily: AppPalette.titleFont,
                                      fontWeight: FontWeight.w500,
                                      color: AppPalette.goldBright,
                                      letterSpacing: 0,
                                      shadows: [
                                        Shadow(
                                          color: AppPalette.gold.withValues(
                                            alpha: 0.42,
                                          ),
                                          blurRadius: 18,
                                        ),
                                      ],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 6 : 8),
                        if (message.isNotEmpty)
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppPalette.ivoryText.withValues(
                                    alpha: 0.72,
                                  ),
                                  fontFamily: AppPalette.serifFont,
                                  letterSpacing: 0,
                                ),
                          ),
                        if (content != null) ...[
                          if (message.isNotEmpty)
                            SizedBox(height: compact ? 16 : 18),
                          content!,
                        ],
                        SizedBox(height: compact ? 20 : 24),
                        for (final (index, action) in actions.indexed) ...[
                          if (index > 0) const SizedBox(height: 4),
                          _ActionButton(
                            action: action,
                            onActionFeedback: onActionFeedback,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActionDialogButton {
  const ActionDialogButton({
    required this.label,
    required this.onPressed,
    this.prominent = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool prominent;
}

class _ActionButton extends HookWidget {
  const _ActionButton({required this.action, required this.onActionFeedback});

  final ActionDialogButton action;
  final VoidCallback? onActionFeedback;
  static const _activationDelay = AppDurations.buttonActivation;

  @override
  Widget build(BuildContext context) {
    final pressed = useState(false);
    final activating = useState(false);

    void setPressed(bool value) {
      if (pressed.value == value) {
        return;
      }

      pressed.value = value;
    }

    Future<void> handleTap() async {
      if (activating.value) {
        return;
      }

      pressed.value = true;
      activating.value = true;
      unawaited(AppHaptics.menuSelect());
      onActionFeedback?.call();

      await Future<void>.delayed(_activationDelay);
      if (!context.mounted) {
        return;
      }

      action.onPressed();

      if (context.mounted) {
        pressed.value = false;
        activating.value = false;
      }
    }

    return Semantics(
      button: true,
      label: action.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: activating.value ? null : (_) => setPressed(true),
        onTapCancel: activating.value ? null : () => setPressed(false),
        onTap: handleTap,
        child: AnimatedScale(
          duration: AppDurations.micro,
          curve: AppCurves.entrance,
          scale: pressed.value ? 1.018 : 1,
          child: SizedBox(
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (pressed.value)
                  Positioned.fill(
                    child: SelectionGlow(
                      key: ValueKey(pressed.value),
                      lineOpacity: 0.56,
                      hazeOpacity: 0.84,
                      revealFromCenter: true,
                      shine: true,
                      intensity: action.prominent ? 0.9 : 0.76,
                      duration: _activationDelay,
                    ),
                  ),
                if (!pressed.value)
                  Positioned(
                    left: 32,
                    right: 32,
                    bottom: 6,
                    height: 1,
                    child: ColoredBox(
                      color: AppPalette.ivoryText.withValues(alpha: 0.12),
                    ),
                  ),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.of(
                    context,
                  ).dialogAction(pressed: pressed.value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
