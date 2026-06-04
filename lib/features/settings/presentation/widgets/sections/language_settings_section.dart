import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tictactoe/core/preferences/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tictactoe/features/settings/presentation/controllers/settings_view_state.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_rows.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

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
    final copy = AppLocalizations.of(context);
    final settingsController = ref.read(settingsControllerProvider.notifier);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final entry in AppLocalePreference.values.indexed) ...[
          SystemLanguageRow(
            index: entry.$1,
            selected: focusedRowIndex == entry.$1,
            active: state.preferences.localePreference == entry.$2,
            label: _languageLabel(copy, entry.$2),
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

  String _languageLabel(
    AppLocalizations copy,
    AppLocalePreference localePreference,
  ) {
    return switch (localePreference) {
      AppLocalePreference.english => copy.englishLanguageLabel,
      AppLocalePreference.french => copy.frenchLanguageLabel,
      AppLocalePreference.spanish => copy.spanishLanguageLabel,
      AppLocalePreference.german => copy.germanLanguageLabel,
    };
  }
}
