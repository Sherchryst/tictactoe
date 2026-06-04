import 'package:tictactoe/features/game/data/models/no_mercy_run_dto.dart';
import 'package:tictactoe/features/game/data/models/no_mercy_run_dto_validator.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';

final class NoMercyRunDtoMapper {
  const NoMercyRunDtoMapper._();

  static NoMercyRunDto fromDomain(GameSession session) {
    return NoMercyRunDto(
      cells: [for (final mark in session.board.cells) mark?.name],
      currentMark: session.currentMark.name,
      bossId: session.bossId.name,
      noMercyCycle: session.noMercyCycle,
      weaknessBroken: session.weaknessBroken,
      humanMoves: session.humanMoves,
      cpuMoves: session.cpuMoves,
      resultType: switch (session.result) {
        GameOngoing() => NoMercyRunDto.resultOngoing,
        GameDraw() => NoMercyRunDto.resultDraw,
        GameWin() => NoMercyRunDto.resultWin,
      },
      winner: switch (session.result) {
        GameWin(:final winner) => winner.name,
        GameOngoing() || GameDraw() => null,
      },
      winningCells: switch (session.result) {
        GameWin(:final winningCells) => winningCells,
        GameOngoing() || GameDraw() => const [],
      },
    );
  }

  static GameSession toDomain(NoMercyRunDto run) {
    NoMercyRunDtoValidator.validate(run);
    final parsedBoard = board(run);

    return GameSession(
      board: parsedBoard,
      currentMark: NoMercyRunDtoValidator.mark(run.currentMark),
      mode: GameMode.noMercyRun,
      bossId: NoMercyRunDtoValidator.bossId(run.bossId),
      noMercyCycle: run.noMercyCycle,
      weaknessBroken: run.weaknessBroken,
      humanMoves: run.humanMoves,
      cpuMoves: run.cpuMoves,
      result: result(run, parsedBoard),
    );
  }

  static Board board(NoMercyRunDto run) {
    return Board(
      cells: [
        for (final cell in run.cells) NoMercyRunDtoValidator.optionalMark(cell),
      ],
    );
  }

  static GameResult result(NoMercyRunDto run, Board board) {
    return switch (run.resultType) {
      NoMercyRunDto.resultOngoing => const GameResult.ongoing(),
      NoMercyRunDto.resultDraw => const GameResult.draw(),
      NoMercyRunDto.resultWin => GameResult.win(
        winner: NoMercyRunDtoValidator.mark(run.winner),
        winningCells: run.winningCells,
      ),
      _ => NoMercyRunDtoValidator.invalid('resultType', run.resultType),
    };
  }
}
