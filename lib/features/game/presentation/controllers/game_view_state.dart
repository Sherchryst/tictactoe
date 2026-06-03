import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';

part 'game_view_state.freezed.dart';

@freezed
abstract class GameViewState with _$GameViewState {
  const GameViewState._();

  const factory GameViewState({
    required GameSession session,
    @Default(false) bool hasRecordedOutcome,
  }) = _GameViewState;

  factory GameViewState.initial() {
    return GameViewState(session: GameSession.newGame(GameSetup.defaults()));
  }
}
