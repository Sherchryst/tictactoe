import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/features/settings/presentation/controllers/settings_view_state.dart';
import 'package:tictactoe/features/settings/presentation/widgets/sections/audio_settings_section.dart';
import 'package:tictactoe/features/settings/presentation/widgets/sections/language_settings_section.dart';
import 'package:tictactoe/features/settings/presentation/widgets/sections/score_settings_section.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_category.dart';

class SettingsContent extends ConsumerWidget {
  const SettingsContent({
    required this.state,
    required this.category,
    required this.focusedRowIndex,
    required this.onFocusRow,
    super.key,
  });

  final SettingsViewState state;
  final SystemCategory category;
  final int focusedRowIndex;
  final ValueChanged<int> onFocusRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = AppBreakpoints.isCompact(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 28,
        compact ? 14 : 20,
        compact ? 12 : 28,
        compact ? 18 : 26,
      ),
      child: switch (category) {
        SystemCategory.audio => AudioSettingsSection(
          focusedRowIndex: focusedRowIndex,
          onFocusRow: onFocusRow,
        ),
        SystemCategory.score => ScoreSettingsSection(
          state: state,
          focusedRowIndex: focusedRowIndex,
          onFocusRow: onFocusRow,
        ),
        SystemCategory.language => LanguageSettingsSection(
          state: state,
          focusedRowIndex: focusedRowIndex,
          onFocusRow: onFocusRow,
        ),
      },
    );
  }
}
