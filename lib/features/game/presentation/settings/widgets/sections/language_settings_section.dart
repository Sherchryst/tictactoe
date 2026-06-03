import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';
import 'package:tictactoe/features/game/presentation/settings/controllers/settings_controller.dart';
import 'package:tictactoe/features/game/presentation/settings/controllers/settings_view_state.dart';
import 'package:tictactoe/features/game/presentation/settings/widgets/system_rows.dart';

class LanguageSettingsSection extends ConsumerWidget {
  const LanguageSettingsSection({
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

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final entry in AppLocalePreference.values.indexed) ...[
          SystemLanguageRow(
            index: entry.$1,
            selected: focusedRowIndex == entry.$1,
            active: state.preferences.localePreference == entry.$2,
            label: copy.languageLabel(entry.$2),
            onFocus: onFocusRow,
            onPressed: () {
              unawaited(settingsController.setLocalePreference(entry.$2));
            },
          ),
          if (entry.$1 != AppLocalePreference.values.length - 1)
            const SizedBox(height: 2),
        ],
      ],
    );
  }
}
