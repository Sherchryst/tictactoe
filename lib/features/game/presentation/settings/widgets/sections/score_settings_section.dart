import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tictactoe/app/di/audio_providers.dart';
import 'package:tictactoe/features/game/domain/entities/menu_sfx.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';
import 'package:tictactoe/features/game/presentation/settings/controllers/settings_controller.dart';
import 'package:tictactoe/features/game/presentation/settings/controllers/settings_view_state.dart';
import 'package:tictactoe/features/game/presentation/settings/widgets/system_rows.dart';

class ScoreSettingsSection extends ConsumerWidget {
  const ScoreSettingsSection({
    required this.state,
    required this.focusedRowIndex,
    required this.onFocusRow,
    super.key,
  });

  final SettingsViewState state;
  final int focusedRowIndex;
  final ValueChanged<int> onFocusRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = GameCopy.of(context);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final audioController = ref.read(audioControllerProvider);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SystemMetricRow(
          index: 0,
          selected: focusedRowIndex == 0,
          label: copy.humanScoreLabel,
          value: state.scoreboard.humanWins.toString(),
          onFocus: onFocusRow,
        ),
        const SizedBox(height: 2),
        SystemMetricRow(
          index: 1,
          selected: focusedRowIndex == 1,
          label: copy.cpuScoreLabel,
          value: state.scoreboard.cpuWins.toString(),
          onFocus: onFocusRow,
        ),
        const SizedBox(height: 2),
        SystemMetricRow(
          index: 2,
          selected: focusedRowIndex == 2,
          label: copy.drawsScoreLabel,
          value: state.scoreboard.draws.toString(),
          onFocus: onFocusRow,
        ),
        const SizedBox(height: 2),
        SystemMetricRow(
          index: 3,
          selected: focusedRowIndex == 3,
          label: copy.duelsFoughtLabel,
          value: state.scoreboard.playedGames.toString(),
          onFocus: onFocusRow,
        ),
        const SizedBox(height: 2),
        SystemActionRow(
          index: 4,
          selected: focusedRowIndex == 4,
          label: copy.resetScoreAction,
          value: copy.resetScoreHint,
          onFocus: onFocusRow,
          onPressed: () {
            unawaited(audioController.playMenuSfx(MenuSfx.reset));
            unawaited(settingsController.resetScoreboard());
          },
        ),
      ],
    );
  }
}
