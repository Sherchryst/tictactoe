import 'package:freezed_annotation/freezed_annotation.dart';

import 'board.dart';
import 'game_difficulty.dart';
import 'game_mode.dart';
import 'game_result.dart';
import 'game_settings.dart';
import 'player.dart';

part 'game_session.freezed.dart';

@freezed
abstract class GameSession with _$GameSession {
  const GameSession._();

  const factory GameSession({
    required Board board,
    required Player currentPlayer,
    @Default(GameMode.humanVsCpu) GameMode mode,
    required GameDifficulty difficulty,
    required GameResult result,
  }) = _GameSession;

  factory GameSession.newGame(GameSettings settings) {
    return GameSession(
      board: Board.empty(),
      currentPlayer: Player.human,
      mode: settings.mode,
      difficulty: settings.difficulty,
      result: const GameResult.ongoing(),
    );
  }

  bool get canHumanPlay {
    if (!result.isOngoing) {
      return false;
    }

    return switch (mode) {
      GameMode.humanVsCpu => currentPlayer == Player.human,
      GameMode.humanVsHuman => true,
    };
  }
}
