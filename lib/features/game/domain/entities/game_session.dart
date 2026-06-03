import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';

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

  factory GameSession.newGame(GameSetup setup) {
    return GameSession(
      board: Board.empty(),
      currentPlayer: Player.human,
      mode: setup.mode,
      difficulty: setup.difficulty,
      result: const GameResult.ongoing(),
    );
  }

  GameSession startNewRound() {
    return copyWith(
      board: Board.empty(),
      currentPlayer: Player.human,
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
