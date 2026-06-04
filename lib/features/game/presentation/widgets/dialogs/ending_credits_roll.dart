import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_animations.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/core/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/core/design_system/widgets/sigil_backdrop.dart';
import 'package:tictactoe/features/game/presentation/widgets/ending_credits_content.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class EndingCreditsRoll extends HookWidget {
  const EndingCreditsRoll({this.onComplete, super.key});

  static const rollDuration = Duration(seconds: 20);

  final VoidCallback? onComplete;

  static Future<void> show({
    required BuildContext context,
    VoidCallback? onComplete,
  }) {
    final l10n = AppLocalizations.of(context);

    return showGeneralDialog<void>(
      context: context,
      barrierLabel: l10n.creditsBarrierLabel,
      barrierColor: AppPalette.backgroundDeep,
      transitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EndingCreditsRoll(onComplete: onComplete);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: rollDuration);

    useEffect(() {
      Future<void> roll() async {
        try {
          await controller.forward().orCancel;
        } on TickerCanceled {
          return;
        }

        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          onComplete?.call();
        }
      }

      unawaited(roll());
      return null;
    }, const []);

    return Material(
      color: AppPalette.backgroundDeep,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppPalette.backgroundDeep),
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.17,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.36,
                child: SigilBackdrop(
                  height: (MediaQuery.sizeOf(context).shortestSide * 1.18)
                      .clamp(410.0, 540.0)
                      .toDouble(),
                ),
              ),
            ),
          ),
          SafeArea(
            child: ClipRect(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = AppBreakpoints.isCompact(context);
                  final creditsHeight = compact ? 640.0 : 720.0;

                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      final progress = controller.value;
                      final eased = Curves.easeInOutCubic.transform(progress);
                      final startY = constraints.maxHeight * 0.64;
                      final endY = -creditsHeight;
                      final top = startY + (endY - startY) * eased;
                      final contentOpacity = _contentOpacity(progress);

                      return Opacity(
                        opacity: contentOpacity,
                        child: Transform.translate(
                          offset: Offset(0, top),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact
                                  ? AppSpacing.lg
                                  : AppSpacing.xxl,
                            ),
                            child: SizedBox(
                              height: creditsHeight,
                              child: EndingCreditsContent(compact: compact),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _contentOpacity(double progress) {
    final fadeIn = AppAnimations.interval(
      progress,
      begin: 0.04,
      end: 0.18,
      curve: Curves.easeInOutCubic,
    );
    final fadeOut =
        1 -
        AppAnimations.interval(
          progress,
          begin: 0.88,
          end: 0.995,
          curve: Curves.easeInOutCubic,
        );

    return (fadeIn * fadeOut).clamp(0.0, 1.0).toDouble();
  }
}
