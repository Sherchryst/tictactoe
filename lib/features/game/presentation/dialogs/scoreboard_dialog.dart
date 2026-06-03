import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/audio/domain/entities/menu_sfx.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/widgets/action_dialog.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';
import 'package:tictactoe/features/game/presentation/controllers/scoreboard_controller.dart';
import 'package:tictactoe/features/game/presentation/utils/text/score_help_resolver.dart';
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

    return ActionDialog(
      title: l10n.recordTitle,
      message: scoreHelp.resolve(-1),
      content: _ScoreboardMetrics(scoreboard: currentScoreboard),
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
            unawaited(
              ref.read(audioControllerProvider).playMenuSfx(MenuSfx.reset),
            );
            unawaited(ref.read(scoreboardControllerProvider.notifier).reset());
          },
        ),
      ],
    );
  }
}

class _ScoreboardMetrics extends StatelessWidget {
  const _ScoreboardMetrics({required this.scoreboard});

  final Scoreboard scoreboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.backgroundDeep.withValues(alpha: 0.32),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: AppPalette.ivoryText.withValues(alpha: AppAlphas.soft),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MetricLine(
              label: l10n.humanScoreLabel,
              value: scoreboard.humanWins,
            ),
            _MetricLine(label: l10n.cpuScoreLabel, value: scoreboard.cpuWins),
            _MetricLine(label: l10n.drawsScoreLabel, value: scoreboard.draws),
            _MetricLine(
              label: l10n.duelsFoughtLabel,
              value: scoreboard.playedGames,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppPalette.ivoryText.withValues(alpha: 0.72),
                fontFamily: AppPalette.serifFont,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppPalette.goldBright,
              fontFamily: AppPalette.titleFont,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
