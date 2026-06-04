import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tictactoe/features/game/domain/entities/mark.dart';

part 'game_result.freezed.dart';

enum GameOutcome { humanWin, cpuWin, draw }

@freezed
sealed class GameResult with _$GameResult {
  const GameResult._();

  const factory GameResult.ongoing() = GameOngoing;

  const factory GameResult.win({
    required Mark winner,
    required List<int> winningCells,
  }) = GameWin;

  const factory GameResult.draw() = GameDraw;

  bool get isOngoing => this is GameOngoing;
}
