import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/entities/participant.dart';
import 'package:tictactoe/features/game/presentation/utils/bosses/boss_presentation.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

final class PlayerLabelResolver {
  const PlayerLabelResolver(this._l10n);

  final AppLocalizations _l10n;

  String badgeName(GameParticipant participant, GameSession session) {
    return switch (participant) {
      HumanParticipant(:final playerId)
          when session.mode == GameMode.localDuel =>
        playerId == HumanPlayerId.playerOne
            ? _l10n.playerOneStatus
            : _l10n.playerTwoStatus,
      HumanParticipant() => _l10n.humanTurnStatus,
      CpuParticipant(:final bossId) => _bossName(bossId, session),
    };
  }

  String markName(Mark mark, GameSession session) {
    return badgeName(session.participantFor(mark), session);
  }

  String result(GameSession session) {
    return switch (session.result) {
      GameWin(:final winner) => _win(session, winner),
      GameDraw() => _l10n.drawDialogTitle,
      GameOngoing() => _l10n.gameTitle,
    };
  }

  String _win(GameSession session, Mark winner) {
    if (session.mode == GameMode.guidedTrial) {
      return session.participantOutcome == GameOutcome.humanWin
          ? _l10n.enemyFelledStatus
          : _l10n.youDiedStatus;
    }

    if (session.mode == GameMode.noMercyRun) {
      return session.participantOutcome == GameOutcome.humanWin
          ? _l10n.demigodFelledStatus
          : _l10n.youDiedStatus;
    }

    return markName(winner, session);
  }

  String _bossName(CpuBossId bossId, GameSession session) {
    return bossId.presentation.name(_l10n);
  }
}
