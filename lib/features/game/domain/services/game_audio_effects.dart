import 'dart:async';

import 'package:tictactoe/core/audio/domain/services/audio_controller.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';

final class GameAudioEffects {
  const GameAudioEffects(this._audio);

  static const parryDuration = Duration(milliseconds: 2064);
  static const drawCriticalImpactDuration = Duration(milliseconds: 1050);
  static const soloVictorySoundDuration = Duration(milliseconds: 7050);
  static const soloDeathBannerDuration = Duration(milliseconds: 1800);

  final AudioController _audio;

  Future<void> playBoardDelta({
    required Board? previousBoard,
    required Board nextBoard,
  }) async {
    if (previousBoard == null) {
      return;
    }

    for (var index = 0; index < Board.cellCount; index++) {
      final before = previousBoard.cellAt(index);
      final after = nextBoard.cellAt(index);
      if (before == Cell.empty && after != Cell.empty) {
        unawaited(_audio.playMove(isPlayerX: after == Cell.human));
      }
    }
  }

  Future<void> playResultIntro(GameResult result, GameMode mode) {
    return switch (result) {
      GameDraw() => _audio.playDraw(),
      GameWin(:final winner)
          when mode == GameMode.humanVsCpu && winner == Player.cpu =>
        _audio.playDeathIntro(),
      GameWin(:final winner)
          when mode == GameMode.humanVsCpu && winner == Player.human =>
        _audio.playParry(),
      GameWin() => _audio.playParry(),
      GameOngoing() => Future<void>.value(),
    };
  }

  Future<void> playDialogReveal(GameResult result, GameMode mode) {
    return switch (result) {
      GameWin(:final winner)
          when mode == GameMode.humanVsCpu && winner == Player.cpu =>
        _audio.playDeath(),
      GameWin(:final winner)
          when mode == GameMode.humanVsCpu && winner == Player.human =>
        _audio.playVictory(),
      GameWin() => _audio.playVictory(),
      GameDraw() || GameOngoing() => Future<void>.value(),
    };
  }

  Duration dialogRevealLeadFor(GameResult result, GameMode mode) {
    return switch (result) {
      GameWin(:final winner)
          when mode == GameMode.humanVsCpu && winner == Player.human =>
        soloVictorySoundDuration,
      GameWin(:final winner)
          when mode == GameMode.humanVsCpu && winner == Player.cpu =>
        const Duration(milliseconds: 1500),
      GameWin() || GameDraw() || GameOngoing() => Duration.zero,
    };
  }

  Duration dialogDelayFor(GameResult result, GameMode mode) {
    return switch (result) {
      GameWin(:final winner)
          when mode == GameMode.humanVsCpu && winner == Player.human =>
        parryDuration,
      GameWin() when mode == GameMode.humanVsCpu => soloDeathBannerDuration,
      GameWin() => const Duration(milliseconds: 1250),
      GameDraw() => drawCriticalImpactDuration,
      GameOngoing() => Duration.zero,
    };
  }
}
