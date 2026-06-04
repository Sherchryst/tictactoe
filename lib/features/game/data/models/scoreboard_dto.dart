import 'package:json_annotation/json_annotation.dart';

import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';

part 'scoreboard_dto.g.dart';

@JsonSerializable(explicitToJson: true)
final class ScoreboardDto {
  const ScoreboardDto({
    required this.radahn,
    required this.mohg,
    required this.malenia,
  });

  factory ScoreboardDto.fromDomain(Scoreboard scoreboard) {
    return ScoreboardDto(
      radahn: BossScoreDto.fromDomain(scoreboard.radahn),
      mohg: BossScoreDto.fromDomain(scoreboard.mohg),
      malenia: BossScoreDto.fromDomain(scoreboard.malenia),
    );
  }

  factory ScoreboardDto.fromJson(Map<String, dynamic> json) {
    return _$ScoreboardDtoFromJson(json);
  }

  final BossScoreDto radahn;
  final BossScoreDto mohg;
  final BossScoreDto malenia;

  Map<String, dynamic> toJson() => _$ScoreboardDtoToJson(this);

  Scoreboard toDomain() {
    return Scoreboard(
      radahn: radahn.toDomain(),
      mohg: mohg.toDomain(),
      malenia: malenia.toDomain(),
    );
  }
}

@JsonSerializable()
final class BossScoreDto {
  const BossScoreDto({
    required this.attempts,
    required this.humanWins,
    required this.cpuWins,
    required this.draws,
  });

  factory BossScoreDto.fromDomain(BossScore score) {
    return BossScoreDto(
      attempts: score.attempts,
      humanWins: score.humanWins,
      cpuWins: score.cpuWins,
      draws: score.draws,
    );
  }

  factory BossScoreDto.fromJson(Map<String, dynamic> json) {
    return _$BossScoreDtoFromJson(json);
  }

  final int attempts;
  final int humanWins;
  final int cpuWins;
  final int draws;

  Map<String, dynamic> toJson() => _$BossScoreDtoToJson(this);

  BossScore toDomain() {
    return BossScore(
      attempts: attempts,
      humanWins: humanWins,
      cpuWins: cpuWins,
      draws: draws,
    );
  }
}
