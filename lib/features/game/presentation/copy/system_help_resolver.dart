import 'package:tictactoe/l10n/app_localizations.dart';

final class SystemHelpResolver {
  const SystemHelpResolver(this._l10n);

  final AppLocalizations _l10n;

  String forAudio(int focusedRowIndex) {
    return switch (focusedRowIndex) {
      0 => _l10n.audioMusicToggleHelp,
      1 => _l10n.audioMusicVolumeHelp,
      2 => _l10n.audioSfxToggleHelp,
      3 => _l10n.audioSfxVolumeHelp,
      _ => _l10n.audioDefaultHelp,
    };
  }

  String forScore(int focusedRowIndex) {
    return switch (focusedRowIndex) {
      0 || 1 || 2 || 3 => _l10n.scoreRecordHelp,
      4 => _l10n.scoreResetHelp,
      _ => _l10n.scoreDefaultHelp,
    };
  }

  String forLanguage(int focusedRowIndex) {
    return switch (focusedRowIndex) {
      0 => _l10n.languageEnglishHelp,
      1 => _l10n.languageFrenchHelp,
      2 => _l10n.languageSpanishHelp,
      3 => _l10n.languageGermanHelp,
      _ => _l10n.languageDefaultHelp,
    };
  }
}
