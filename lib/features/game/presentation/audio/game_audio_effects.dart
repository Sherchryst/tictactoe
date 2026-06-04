import 'dart:async';

import 'package:tictactoe/core/audio/domain/services/audio_controller.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/participant.dart';

final class GameAudioEffects {
  const GameAudioEffects(this._audio);

  static const parryDuration = Duration(milliseconds: 2064);
  static const noMercyVictoryBannerDelay = Duration(milliseconds: 1000);
  static const drawCriticalImpactDuration = Duration(milliseconds: 1050);
  static const soloVictorySoundDuration = Duration(milliseconds: 7050);
  static const soloDeathBannerDuration = Duration(milliseconds: 1800);
  static const guidedVictoryDelay = Duration(milliseconds: 900);
  static const bossRuneIntroSoundDelay = Duration(milliseconds: 220);

  final AudioController _audio;

  Future<void> playBoardDelta({
    required Board? previousBoard,
    required GameSession nextSession,
  }) async {
    if (previousBoard == null) {
      return;
    }

    for (var index = 0; index < Board.cellCount; index++) {
      final before = previousBoard.markAt(index);
      final after = nextSession.board.markAt(index);
      if (before == null && after != null) {
        final participant = nextSession.participantFor(after);
        if (participant.kind == ParticipantKind.cpu) {
          unawaited(_audio.playCpuMark());
        } else {
          unawaited(_audio.playHumanMark());
        }
      }
    }
  }

  Future<void> playBossRuneIntro(GameSession session) {
    if (!session.hasCpuOpponent || !session.result.isOngoing) {
      return Future<void>.value();
    }

    return _audio.playCpuMark();
  }

  Future<void> playResultIntro(GameSession session) {
    return switch (session.result) {
      GameDraw() => _audio.playDraw(),
      GameWin()
          when session.mode != GameMode.localDuel &&
              session.participantOutcome == GameOutcome.cpuWin =>
        _audio.playDeathIntro(),
      GameWin() => _audio.playParry(),
      GameOngoing() => Future<void>.value(),
    };
  }

  Future<void> playDialogReveal(GameSession session) {
    return switch (session.result) {
      GameWin()
          when session.mode != GameMode.localDuel &&
              session.participantOutcome == GameOutcome.cpuWin =>
        _playCpuWinReveal(session),
      GameWin() => _audio.playVictory(),
      GameDraw() || GameOngoing() => Future<void>.value(),
    };
  }

  Duration dialogRevealLeadFor(GameSession session) {
    return switch (session.result) {
      GameWin()
          when session.mode != GameMode.localDuel &&
              session.participantOutcome == GameOutcome.humanWin =>
        soloVictorySoundDuration,
      GameWin()
          when session.mode != GameMode.localDuel &&
              session.participantOutcome == GameOutcome.cpuWin =>
        const Duration(milliseconds: 1500),
      GameWin() || GameDraw() || GameOngoing() => Duration.zero,
    };
  }

  Duration dialogDelayFor(GameSession session) {
    return switch (session.result) {
      GameWin()
          when session.mode == GameMode.guidedTrial &&
              session.participantOutcome == GameOutcome.humanWin =>
        guidedVictoryDelay,
      GameWin()
          when session.mode == GameMode.noMercyRun &&
              session.participantOutcome == GameOutcome.humanWin =>
        noMercyVictoryBannerDelay,
      GameWin()
          when session.mode != GameMode.localDuel &&
              session.participantOutcome == GameOutcome.cpuWin =>
        soloDeathBannerDuration,
      GameWin() => const Duration(milliseconds: 1250),
      GameDraw() => drawCriticalImpactDuration,
      GameOngoing() => Duration.zero,
    };
  }

  Future<void> _playCpuWinReveal(GameSession session) async {
    await _audio.playDeath();
    if (session.bossId == CpuBossId.malenia) {
      await _audio.playMaleniaVictoryLine();
    }
  }
}
