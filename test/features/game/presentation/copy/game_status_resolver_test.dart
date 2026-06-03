import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/presentation/copy/game_status_resolver.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final resolver = GameStatusResolver(l10n);

  group('GameStatusResolver', () {
    test('returns the current player turn label when ongoing', () {
      expect(
        resolver.resolve(
          const GameResult.ongoing(),
          Player.human,
          GameMode.humanVsCpu,
        ),
        l10n.humanTurnStatus,
      );
    });

    test('returns the winner label when there is a win', () {
      expect(
        resolver.resolve(
          const GameResult.win(winner: Player.cpu, winningCells: [0, 1, 2]),
          Player.human,
          GameMode.humanVsCpu,
        ),
        l10n.cpuWinStatus,
      );
    });

    test('returns the draw status when the result is a draw', () {
      expect(
        resolver.resolve(
          const GameResult.draw(),
          Player.human,
          GameMode.humanVsCpu,
        ),
        l10n.drawStatus,
      );
    });
  });
}
