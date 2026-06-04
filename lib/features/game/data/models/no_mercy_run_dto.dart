import 'package:tictactoe/features/game/data/models/no_mercy_run_dto_mapper.dart';
import 'package:tictactoe/features/game/data/models/no_mercy_run_dto_validator.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';

final class NoMercyRunDto {
  const NoMercyRunDto({
    required this.cells,
    required this.currentMark,
    required this.bossId,
    required this.noMercyCycle,
    required this.weaknessBroken,
    required this.humanMoves,
    required this.cpuMoves,
    required this.resultType,
    required this.winner,
    required this.winningCells,
  });

  factory NoMercyRunDto.fromDomain(GameSession session) {
    return NoMercyRunDtoMapper.fromDomain(session);
  }

  factory NoMercyRunDto.fromJson(Map<String, dynamic> json) {
    final run = NoMercyRunDto(
      cells: NoMercyRunDtoValidator.cells(json['cells']),
      currentMark: NoMercyRunDtoValidator.requiredMarkName(
        json['currentMark'],
        'currentMark',
      ),
      bossId: NoMercyRunDtoValidator.requiredBossName(json['bossId']),
      noMercyCycle: NoMercyRunDtoValidator.cycle(json['noMercyCycle']),
      weaknessBroken: NoMercyRunDtoValidator.boolean(
        json['weaknessBroken'],
        'weaknessBroken',
      ),
      humanMoves: NoMercyRunDtoValidator.cellIndexes(
        json['humanMoves'],
        'humanMoves',
      ),
      cpuMoves: NoMercyRunDtoValidator.cellIndexes(
        json['cpuMoves'],
        'cpuMoves',
      ),
      resultType: NoMercyRunDtoValidator.resultType(json['resultType']),
      winner: NoMercyRunDtoValidator.optionalMarkName(json['winner'], 'winner'),
      winningCells: NoMercyRunDtoValidator.cellIndexes(
        json['winningCells'],
        'winningCells',
      ),
    );
    NoMercyRunDtoValidator.validate(run);
    return run;
  }

  static const resultOngoing = 'ongoing';
  static const resultDraw = 'draw';
  static const resultWin = 'win';

  final List<String?> cells;
  final String currentMark;
  final String bossId;
  final int noMercyCycle;
  final bool weaknessBroken;
  final List<int> humanMoves;
  final List<int> cpuMoves;
  final String resultType;
  final String? winner;
  final List<int> winningCells;

  Map<String, Object?> toJson() {
    return {
      'cells': cells,
      'currentMark': currentMark,
      'bossId': bossId,
      'noMercyCycle': noMercyCycle,
      'weaknessBroken': weaknessBroken,
      'humanMoves': humanMoves,
      'cpuMoves': cpuMoves,
      'resultType': resultType,
      'winner': winner,
      'winningCells': winningCells,
    };
  }

  GameSession toDomain() {
    return NoMercyRunDtoMapper.toDomain(this);
  }
}
