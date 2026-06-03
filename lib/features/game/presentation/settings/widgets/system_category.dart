import 'package:flutter/material.dart';

import 'package:tictactoe/features/game/presentation/game_copy.dart';

enum SystemCategory { audio, language, score }

extension SystemCategoryX on SystemCategory {
  String title(GameCopy copy) {
    return switch (this) {
      SystemCategory.audio => copy.soundOptionsTitle,
      SystemCategory.language => copy.languageOptionsTitle,
      SystemCategory.score => copy.recordTitle,
    };
  }

  String shortLabel(GameCopy copy) {
    return switch (this) {
      SystemCategory.audio => copy.audioTitle,
      SystemCategory.language => copy.languageTitle,
      SystemCategory.score => copy.scoreTitle,
    };
  }

  IconData get icon {
    return switch (this) {
      SystemCategory.audio => Icons.graphic_eq_rounded,
      SystemCategory.language => Icons.language_rounded,
      SystemCategory.score => Icons.military_tech_rounded,
    };
  }

  String helpText(GameCopy copy, int focusedRowIndex) {
    return switch (this) {
      SystemCategory.audio => copy.helpTextForAudio(focusedRowIndex),
      SystemCategory.language => copy.helpTextForLanguage(focusedRowIndex),
      SystemCategory.score => copy.helpTextForScore(focusedRowIndex),
    };
  }
}
