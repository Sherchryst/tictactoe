import 'package:tictactoe/l10n/app_localizations.dart';

final class ScoreHelpResolver {
  const ScoreHelpResolver(this._l10n);

  final AppLocalizations _l10n;

  String resolve(int focusedRowIndex) {
    return switch (focusedRowIndex) {
      0 || 1 || 2 || 3 => _l10n.scoreRecordHelp,
      4 => _l10n.scoreResetHelp,
      _ => _l10n.scoreDefaultHelp,
    };
  }
}
