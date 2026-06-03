import 'package:json_annotation/json_annotation.dart';

import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';

part 'scoreboard_dto.g.dart';

@JsonSerializable()
final class ScoreboardDto {
  const ScoreboardDto({
    required this.humanWins,
    required this.cpuWins,
    required this.draws,
  });

  factory ScoreboardDto.fromDomain(Scoreboard scoreboard) {
    return ScoreboardDto(
      humanWins: scoreboard.humanWins,
      cpuWins: scoreboard.cpuWins,
      draws: scoreboard.draws,
    );
  }

  factory ScoreboardDto.fromJson(Map<String, dynamic> json) {
    return _$ScoreboardDtoFromJson(json);
  }

  final int humanWins;
  final int cpuWins;
  final int draws;

  Map<String, dynamic> toJson() => _$ScoreboardDtoToJson(this);

  Scoreboard toDomain() {
    return Scoreboard(humanWins: humanWins, cpuWins: cpuWins, draws: draws);
  }
}
