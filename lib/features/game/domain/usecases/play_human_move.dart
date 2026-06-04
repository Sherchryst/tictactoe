import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/services/boss_pattern_catalog.dart';
import 'package:tictactoe/features/game/domain/usecases/play_move.dart';

final class PlayHumanMove {
  const PlayHumanMove({PlayMove playMove = const PlayMove()})
    : _playMove = playMove;

  final PlayMove _playMove;

  GameSession call(GameSession session, int cellIndex) {
    if (!session.canHumanPlay) {
      return session;
    }

    final afterHuman = _playMove(session, session.currentMark, cellIndex);
    if (afterHuman == session) {
      return session;
    }

    if (!session.hasCpuOpponent) {
      return afterHuman;
    }

    final humanMoves = [...session.humanMoves, cellIndex];
    final pattern = session.isNoMercy
        ? BossPatterns.forBoss(
            session.bossId,
            noMercyCycle: session.noMercyCycle,
          )
        : null;
    final weaknessBroken =
        session.weaknessBroken ||
        (pattern != null && !pattern.matchesHumanPrefix(humanMoves));

    return afterHuman.copyWith(
      humanMoves: humanMoves,
      weaknessBroken: weaknessBroken,
    );
  }
}
