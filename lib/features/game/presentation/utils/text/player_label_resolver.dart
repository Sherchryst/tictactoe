import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

final class PlayerLabelResolver {
  const PlayerLabelResolver(this._l10n);

  final AppLocalizations _l10n;

  String score(Player player, GameMode mode) {
    return switch (mode) {
      GameMode.humanVsCpu =>
        player == Player.human ? _l10n.humanScoreLabel : _l10n.cpuScoreLabel,
      GameMode.humanVsHuman =>
        player == Player.human ? _l10n.humanScoreLabel : _l10n.cpuScoreLabel,
    };
  }

  String win(Player player, GameMode mode) {
    return switch (mode) {
      GameMode.humanVsCpu =>
        player == Player.human ? _l10n.humanWinStatus : _l10n.cpuWinStatus,
      GameMode.humanVsHuman =>
        player == Player.human ? _l10n.humanWinStatus : _l10n.cpuWinStatus,
    };
  }
}
