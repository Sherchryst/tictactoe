import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_rows.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class AudioSettingsSection extends ConsumerWidget {
  const AudioSettingsSection({
    required this.focusedRowIndex,
    required this.onFocusRow,
    super.key,
  });

  final int focusedRowIndex;
  final ValueChanged<int> onFocusRow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppLocalizations.of(context);
    final audio = ref.watch(audioPreferencesProvider);
    final audioController = ref.read(audioPreferencesControllerProvider);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SystemToggleRow(
          index: 0,
          selected: focusedRowIndex == 0,
          label: copy.musicTitle,
          value: audio.musicEnabled,
          onFocus: onFocusRow,
          onChanged: audioController.setMusicEnabled,
        ),
        const SizedBox(height: 2),
        SystemSliderRow(
          index: 1,
          selected: focusedRowIndex == 1,
          label: copy.musicVolumeLabel,
          value: audio.musicVolume,
          enabled: audio.musicEnabled,
          onFocus: onFocusRow,
          onChanged: audioController.setMusicVolume,
        ),
        const SizedBox(height: 2),
        SystemToggleRow(
          index: 2,
          selected: focusedRowIndex == 2,
          label: copy.sfxTitle,
          value: audio.sfxEnabled,
          onFocus: onFocusRow,
          onChanged: audioController.setSfxEnabled,
        ),
        const SizedBox(height: 2),
        SystemSliderRow(
          index: 3,
          selected: focusedRowIndex == 3,
          label: copy.sfxVolumeLabel,
          value: audio.sfxVolume,
          enabled: audio.sfxEnabled,
          onFocus: onFocusRow,
          onChanged: audioController.setSfxVolume,
        ),
      ],
    );
  }
}
