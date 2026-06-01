import 'package:freezed_annotation/freezed_annotation.dart';

import 'game_outcome.dart';
import 'player.dart';

part 'game_result.freezed.dart';

@freezed
sealed class GameResult with _$GameResult {
  const GameResult._();

  const factory GameResult.ongoing() = GameOngoing;

  const factory GameResult.win({
    required Player winner,
    required List<int> winningCells,
  }) = GameWin;

  const factory GameResult.draw() = GameDraw;

  bool get isOngoing => this is GameOngoing;

  GameOutcome? get outcome {
    return switch (this) {
      GameWin(:final winner) =>
        winner == Player.human ? GameOutcome.humanWin : GameOutcome.cpuWin,
      GameDraw() => GameOutcome.draw,
      GameOngoing() => null,
    };
  }
}
