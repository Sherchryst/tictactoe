import 'package:flutter/material.dart';

import 'package:tictactoe/l10n/app_localizations.dart';

enum SystemCategory { audio, score, language }

extension SystemCategoryX on SystemCategory {
  String title(AppLocalizations copy) {
    return switch (this) {
      SystemCategory.audio => copy.soundOptionsTitle,
      SystemCategory.score => copy.scoreOptionsTitle,
      SystemCategory.language => copy.languageOptionsTitle,
    };
  }

  String shortLabel(AppLocalizations copy) {
    return switch (this) {
      SystemCategory.audio => copy.audioTitle,
      SystemCategory.score => copy.scoreTitle,
      SystemCategory.language => copy.languageTitle,
    };
  }

  IconData get icon {
    return switch (this) {
      SystemCategory.audio => Icons.graphic_eq_rounded,
      SystemCategory.score => Icons.history_rounded,
      SystemCategory.language => Icons.language_rounded,
    };
  }

  String helpText(AppLocalizations copy, int focusedRowIndex) {
    return switch (this) {
      SystemCategory.audio => switch (focusedRowIndex) {
        0 => copy.audioMusicToggleHelp,
        1 => copy.audioMusicVolumeHelp,
        2 => copy.audioSfxToggleHelp,
        3 => copy.audioSfxVolumeHelp,
        _ => copy.audioDefaultHelp,
      },
      SystemCategory.score => switch (focusedRowIndex) {
        0 => copy.scoreResetConfirmationHelp,
        _ => copy.scoreDefaultHelp,
      },
      SystemCategory.language => switch (focusedRowIndex) {
        0 => copy.languageEnglishHelp,
        1 => copy.languageFrenchHelp,
        2 => copy.languageSpanishHelp,
        3 => copy.languageGermanHelp,
        _ => copy.languageDefaultHelp,
      },
    };
  }
}
