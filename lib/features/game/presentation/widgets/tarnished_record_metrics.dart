import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class TarnishedRecordMetrics extends StatelessWidget {
  const TarnishedRecordMetrics({required this.scoreboard, super.key});

  final Scoreboard scoreboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final record = scoreboard.tarnishedRecord;

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
            Text(
              l10n.tarnishedRecordTitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppPalette.goldBright,
                fontFamily: AppPalette.titleFont,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            _MetricLine(
              label: l10n.tarnishedVictoryLabel,
              value: record.humanWins,
            ),
            _MetricLine(
              label: l10n.tarnishedDefeatLabel,
              value: record.cpuWins,
            ),
            _MetricLine(label: l10n.tarnishedDrawLabel, value: record.draws),
            _MetricLine(
              label: l10n.tarnishedFightLabel,
              value: record.attempts,
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
