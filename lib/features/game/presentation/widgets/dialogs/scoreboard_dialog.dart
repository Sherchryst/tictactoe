import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/audio/domain/entities/menu_sfx.dart';
import 'package:tictactoe/core/design_system/widgets/action_dialog.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/preferences/application/controllers/app_preferences_controller.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';
import 'package:tictactoe/features/game/presentation/controllers/scoreboard_controller.dart';
import 'package:tictactoe/features/game/presentation/utils/text/score_help_resolver.dart';
import 'package:tictactoe/features/game/presentation/widgets/dialogs/score_reset_confirmation_dialog.dart';
import 'package:tictactoe/features/game/presentation/widgets/tarnished_record_metrics.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class ScoreboardDialog extends ConsumerWidget {
  const ScoreboardDialog({super.key});

  static Future<void> show(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return showActionDialog<void>(
      context: context,
      barrierLabel: l10n.recordTitle,
      builder: (_) => const ScoreboardDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scoreHelp = ScoreHelpResolver(l10n);
    final scoreboard = ref.watch(scoreboardControllerProvider).value;
    final currentScoreboard = scoreboard ?? Scoreboard.empty();
    final confirmReset =
        ref.watch(appPreferencesControllerProvider).value?.confirmScoreReset ??
        true;

    return ActionDialog(
      title: l10n.recordTitle,
      message: scoreHelp.resolve(-1),
      content: TarnishedRecordMetrics(scoreboard: currentScoreboard),
      onActionFeedback: () {
        unawaited(
          ref.read(audioControllerProvider).playMenuSfx(MenuSfx.select),
        );
      },
      actions: [
        ActionDialogButton(
          label: l10n.backTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
        ActionDialogButton(
          label: l10n.resetScoreAction,
          prominent: true,
          onPressed: () {
            unawaited(_resetScore(context, ref, confirmReset));
          },
        ),
      ],
    );
  }

  Future<void> _resetScore(
    BuildContext context,
    WidgetRef ref,
    bool confirmReset,
  ) async {
    if (confirmReset) {
      final result = await showScoreResetConfirmationDialog(context: context);
      if (result == null) {
        return;
      }

      if (result.doNotAskAgain) {
        await ref
            .read(appPreferencesControllerProvider.notifier)
            .setConfirmScoreReset(false);
      }
    }

    unawaited(ref.read(audioControllerProvider).playMenuSfx(MenuSfx.reset));
    await ref.read(scoreboardControllerProvider.notifier).reset();
  }
}
