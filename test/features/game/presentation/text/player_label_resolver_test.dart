import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/presentation/utils/text/player_label_resolver.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final resolver = PlayerLabelResolver(l10n);

  GameSession session({
    GameMode mode = GameMode.guidedTrial,
    CpuBossId bossId = CpuBossId.guided,
    int noMercyCycle = 0,
    GameResult result = const GameResult.ongoing(),
  }) {
    return GameSession.newGame(switch (mode) {
      GameMode.localDuel => GameSetup.localDuel(),
      GameMode.guidedTrial => GameSetup.guidedTrial(),
      GameMode.noMercyRun => GameSetup.noMercy(
        bossId,
        noMercyCycle: noMercyCycle,
      ),
    }).copyWith(result: result);
  }

  group('PlayerLabelResolver', () {
    test('returns local human labels from participant mapping', () {
      final local = session(mode: GameMode.localDuel);

      expect(resolver.markName(Mark.x, local), l10n.playerOneStatus);
      expect(resolver.markName(Mark.o, local), l10n.playerTwoStatus);
    });

    test('returns boss labels from presentation profile', () {
      final noMercy = session(
        mode: GameMode.noMercyRun,
        bossId: CpuBossId.malenia,
      );

      expect(resolver.markName(Mark.o, noMercy), l10n.bossMaleniaName);
    });

    test('does not append NG+ to No Mercy boss labels', () {
      final noMercy = session(
        mode: GameMode.noMercyRun,
        bossId: CpuBossId.radahn,
        noMercyCycle: 3,
      );

      expect(resolver.markName(Mark.o, noMercy), l10n.bossRadahnName);
      expect(resolver.markName(Mark.o, noMercy), isNot(contains('NG+')));
    });

    test('returns exact guided and No Mercy victory messages', () {
      expect(
        resolver.result(
          session(
            result: const GameResult.win(
              winner: Mark.x,
              winningCells: [0, 1, 2],
            ),
          ),
        ),
        l10n.enemyFelledStatus,
      );
      expect(
        resolver.result(
          session(
            mode: GameMode.noMercyRun,
            bossId: CpuBossId.radahn,
            result: const GameResult.win(
              winner: Mark.x,
              winningCells: [0, 1, 2],
            ),
          ),
        ),
        l10n.demigodFelledStatus,
      );
    });

    test('returns YOU DIED when a boss wins', () {
      expect(
        resolver.result(
          session(
            mode: GameMode.noMercyRun,
            bossId: CpuBossId.mohg,
            result: const GameResult.win(
              winner: Mark.o,
              winningCells: [0, 4, 8],
            ),
          ),
        ),
        l10n.youDiedStatus,
      );
    });
  });
}
