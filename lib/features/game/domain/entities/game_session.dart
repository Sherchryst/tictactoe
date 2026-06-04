import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/entities/participant.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_rules.dart';

part 'game_session.freezed.dart';

@freezed
abstract class GameSession with _$GameSession {
  const GameSession._();

  const factory GameSession({
    required Board board,
    required Mark currentMark,
    @Default(GameMode.guidedTrial) GameMode mode,
    required CpuBossId bossId,
    @Default(0) int noMercyCycle,
    @Default(Mark.x) Mark humanMark,
    @Default(Mark.o) Mark opponentMark,
    @Default(false) bool weaknessBroken,
    @Default(<int>[]) List<int> humanMoves,
    @Default(<int>[]) List<int> cpuMoves,
    required GameResult result,
  }) = _GameSession;

  factory GameSession.newGame(GameSetup setup) {
    return GameSession(
      board: Board.empty(),
      currentMark: Mark.x,
      mode: setup.mode,
      bossId: setup.mode == GameMode.localDuel
          ? CpuBossId.guided
          : setup.bossId,
      noMercyCycle: setup.noMercyCycle,
      result: const GameResult.ongoing(),
    );
  }

  GameSession startNewRound({CpuBossId? bossId, int? noMercyCycle}) {
    return copyWith(
      board: Board.empty(),
      currentMark: humanMark,
      bossId: bossId ?? this.bossId,
      noMercyCycle: (noMercyCycle ?? this.noMercyCycle)
          .clamp(0, maxNoMercyCycle)
          .toInt(),
      weaknessBroken: false,
      humanMoves: const [],
      cpuMoves: const [],
      result: const GameResult.ongoing(),
    );
  }

  bool get canHumanPlay {
    if (!result.isOngoing) {
      return false;
    }

    return switch (mode) {
      GameMode.localDuel => true,
      GameMode.guidedTrial || GameMode.noMercyRun => currentMark == humanMark,
    };
  }

  bool get hasCpuOpponent {
    return switch (mode) {
      GameMode.localDuel => false,
      GameMode.guidedTrial || GameMode.noMercyRun => true,
    };
  }

  bool get isNoMercy => mode == GameMode.noMercyRun;

  CpuBossId? get noMercyBossId => isNoMercy ? bossId : null;

  bool get canAdvanceToNextNoMercyBoss {
    return isNoMercy &&
        participantOutcome == GameOutcome.humanWin &&
        (bossId.nextNoMercyBoss != null ||
            (bossId == CpuBossId.malenia && noMercyCycle < maxNoMercyCycle));
  }

  bool get defeatedNoMercyFinalBoss {
    return isNoMercy &&
        bossId == CpuBossId.malenia &&
        participantOutcome == GameOutcome.humanWin;
  }

  bool get completedMaxNoMercyCycle {
    return defeatedNoMercyFinalBoss && noMercyCycle >= maxNoMercyCycle;
  }

  Mark get cpuMark => opponentMark;

  GameParticipant participantFor(Mark mark) {
    if (mode == GameMode.localDuel) {
      return HumanParticipant(
        mark: mark,
        playerId: mark == Mark.x
            ? HumanPlayerId.playerOne
            : HumanPlayerId.playerTwo,
      );
    }

    if (mark == humanMark) {
      return HumanParticipant(mark: mark, playerId: HumanPlayerId.playerOne);
    }

    return CpuParticipant(mark: mark, bossId: bossId);
  }

  GameOutcome? get participantOutcome {
    return switch (result) {
      GameWin(:final winner) =>
        participantFor(winner).kind == ParticipantKind.human
            ? GameOutcome.humanWin
            : GameOutcome.cpuWin,
      GameDraw() => GameOutcome.draw,
      GameOngoing() => null,
    };
  }
}
