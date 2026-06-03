import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/presentation/copy/player_label_resolver.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';

void main() {
  final resolver = PlayerLabelResolver(AppLocalizationsEn());
  final l10n = AppLocalizationsEn();

  group('PlayerLabelResolver', () {
    test('returns the human score label for the human player', () {
      expect(
        resolver.score(Player.human, GameMode.humanVsCpu),
        l10n.humanScoreLabel,
      );
    });

    test('returns the cpu score label for the cpu player', () {
      expect(
        resolver.score(Player.cpu, GameMode.humanVsCpu),
        l10n.cpuScoreLabel,
      );
    });

    test('returns the win label for the winner in solo', () {
      expect(
        resolver.win(Player.human, GameMode.humanVsCpu),
        l10n.humanWinStatus,
      );
      expect(resolver.win(Player.cpu, GameMode.humanVsCpu), l10n.cpuWinStatus);
    });

    test('returns the turn label for the active player', () {
      expect(
        resolver.turn(Player.human, GameMode.humanVsCpu),
        l10n.humanTurnStatus,
      );
      expect(
        resolver.turn(Player.cpu, GameMode.humanVsCpu),
        l10n.cpuTurnStatus,
      );
    });
  });
}
