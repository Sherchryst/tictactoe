import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/presentation/copy/player_label_resolver.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

final class GameStatusResolver {
  GameStatusResolver(AppLocalizations l10n)
    : _l10n = l10n,
      _playerLabels = PlayerLabelResolver(l10n);

  final AppLocalizations _l10n;
  final PlayerLabelResolver _playerLabels;

  String resolve(GameResult result, Player currentPlayer, GameMode mode) {
    return switch (result) {
      GameOngoing() => _playerLabels.turn(currentPlayer, mode),
      GameWin(:final winner) => _playerLabels.win(winner, mode),
      GameDraw() => _l10n.drawStatus,
    };
  }
}
