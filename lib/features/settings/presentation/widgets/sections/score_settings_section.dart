import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tictactoe/features/settings/presentation/controllers/settings_view_state.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_rows.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

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
    final copy = AppLocalizations.of(context);
    final settingsController = ref.read(settingsControllerProvider.notifier);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SystemToggleRow(
          index: 0,
          selected: focusedRowIndex == 0,
          label: copy.scoreResetConfirmationLabel,
          value: state.preferences.confirmScoreReset,
          onFocus: onFocusRow,
          onChanged: (value) {
            unawaited(settingsController.setConfirmScoreReset(value));
          },
        ),
      ],
    );
  }
}
