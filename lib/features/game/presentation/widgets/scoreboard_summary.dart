import 'package:flutter/material.dart';

import '../../domain/entities/game_mode.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/scoreboard.dart';
import '../game_copy.dart';

class ScoreboardSummary extends StatelessWidget {
  const ScoreboardSummary({
    required this.scoreboard,
    this.mode = GameMode.humanVsCpu,
    super.key,
  });

  final Scoreboard scoreboard;
  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ScoreTile(
            label: GameCopy.scoreLabelFor(Player.human, mode),
            value: scoreboard.humanWins,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ScoreTile(
            label: GameCopy.scoreLabelFor(Player.cpu, mode),
            value: scoreboard.cpuWins,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ScoreTile(
            label: GameCopy.drawsScoreLabel,
            value: scoreboard.draws,
          ),
        ),
      ],
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(label),
          ],
        ),
      ),
    );
  }
}
