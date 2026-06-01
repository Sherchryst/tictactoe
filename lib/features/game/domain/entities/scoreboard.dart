import 'package:freezed_annotation/freezed_annotation.dart';

import 'game_outcome.dart';

part 'scoreboard.freezed.dart';

@freezed
abstract class Scoreboard with _$Scoreboard {
  const Scoreboard._();

  const factory Scoreboard({
    @Default(0) int humanWins,
    @Default(0) int cpuWins,
    @Default(0) int draws,
  }) = _Scoreboard;

  factory Scoreboard.empty() => const Scoreboard();

  int get playedGames => humanWins + cpuWins + draws;

  Scoreboard record(GameOutcome outcome) {
    return switch (outcome) {
      GameOutcome.humanWin => copyWith(humanWins: humanWins + 1),
      GameOutcome.cpuWin => copyWith(cpuWins: cpuWins + 1),
      GameOutcome.draw => copyWith(draws: draws + 1),
    };
  }
}
