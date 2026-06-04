import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';

part 'scoreboard.freezed.dart';

@freezed
abstract class BossScore with _$BossScore {
  const BossScore._();

  const factory BossScore({
    @Default(0) int attempts,
    @Default(0) int humanWins,
    @Default(0) int cpuWins,
    @Default(0) int draws,
  }) = _BossScore;

  factory BossScore.empty() => const BossScore();

  BossScore record(GameOutcome outcome) {
    return switch (outcome) {
      GameOutcome.humanWin => copyWith(
        attempts: attempts + 1,
        humanWins: humanWins + 1,
      ),
      GameOutcome.cpuWin => copyWith(
        attempts: attempts + 1,
        cpuWins: cpuWins + 1,
      ),
      GameOutcome.draw => copyWith(attempts: attempts + 1, draws: draws + 1),
    };
  }
}

@freezed
abstract class Scoreboard with _$Scoreboard {
  const Scoreboard._();

  const factory Scoreboard({
    @Default(BossScore()) BossScore radahn,
    @Default(BossScore()) BossScore mohg,
    @Default(BossScore()) BossScore malenia,
  }) = _Scoreboard;

  factory Scoreboard.empty() => const Scoreboard();

  int get playedGames => radahn.attempts + mohg.attempts + malenia.attempts;

  BossScore get tarnishedRecord {
    return BossScore(
      attempts: playedGames,
      humanWins: radahn.humanWins + mohg.humanWins + malenia.humanWins,
      cpuWins: radahn.cpuWins + mohg.cpuWins + malenia.cpuWins,
      draws: radahn.draws + mohg.draws + malenia.draws,
    );
  }

  BossScore bossScore(CpuBossId bossId) {
    return switch (bossId) {
      CpuBossId.guided => BossScore.empty(),
      CpuBossId.radahn => radahn,
      CpuBossId.mohg => mohg,
      CpuBossId.malenia => malenia,
    };
  }

  Scoreboard record(CpuBossId bossId, GameOutcome outcome) {
    return switch (bossId) {
      CpuBossId.guided => this,
      CpuBossId.radahn => copyWith(radahn: radahn.record(outcome)),
      CpuBossId.mohg => copyWith(mohg: mohg.record(outcome)),
      CpuBossId.malenia => copyWith(malenia: malenia.record(outcome)),
    };
  }
}
