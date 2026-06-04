import 'package:tictactoe/features/game/data/models/no_mercy_run_dto.dart';
import 'package:tictactoe/features/game/data/models/no_mercy_run_dto_mapper.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/game_rules.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_rules.dart';

final class NoMercyRunDtoValidator {
  const NoMercyRunDtoValidator._();

  static void validate(NoMercyRunDto run) {
    final board = NoMercyRunDtoMapper.board(run);
    final current = mark(run.currentMark);
    bossId(run.bossId);
    _validateMoveHistory(run, board);
    _validateCurrentMark(run, current);
    _validateResult(run, board);
  }

  static List<String?> cells(Object? value) {
    if (value is! List || value.length != Board.cellCount) {
      return invalid('cells', value);
    }

    return [
      for (final item in value)
        if (item == null) null else requiredMarkName(item, 'cells'),
    ];
  }

  static List<int> cellIndexes(Object? value, String field) {
    if (value is! List) {
      return invalid(field, value);
    }

    final indexes = <int>[];
    for (final item in value) {
      if (item is! int || item < 0 || item >= Board.cellCount) {
        invalid(field, value);
      }
      indexes.add(item);
    }
    if (indexes.toSet().length != indexes.length) {
      invalid(field, value);
    }
    return indexes;
  }

  static int cycle(Object? value) {
    if (value is! int || value < 0 || value > maxNoMercyCycle) {
      return invalid('noMercyCycle', value);
    }

    return value;
  }

  static CpuBossId bossId(String value) {
    for (final bossId in CpuBossId.values) {
      if (bossId.name == value && bossId.isNoMercy) {
        return bossId;
      }
    }

    return invalid('bossId', value);
  }

  static Mark mark(String? value) {
    for (final mark in Mark.values) {
      if (mark.name == value) {
        return mark;
      }
    }

    return invalid('mark', value);
  }

  static Mark? optionalMark(String? value) {
    if (value == null) {
      return null;
    }

    for (final mark in Mark.values) {
      if (mark.name == value) {
        return mark;
      }
    }

    return invalid('cells', value);
  }

  static String requiredBossName(Object? value) {
    if (value is! String) {
      return invalid('bossId', value);
    }

    return bossId(value).name;
  }

  static String requiredMarkName(Object? value, String field) {
    if (value is! String) {
      return invalid(field, value);
    }

    return mark(value).name;
  }

  static String? optionalMarkName(Object? value, String field) {
    if (value == null) {
      return null;
    }
    if (value is! String) {
      return invalid(field, value);
    }

    return mark(value).name;
  }

  static bool boolean(Object? value, String field) {
    if (value is bool) {
      return value;
    }

    return invalid(field, value);
  }

  static String resultType(Object? value) {
    return switch (value) {
      NoMercyRunDto.resultOngoing ||
      NoMercyRunDto.resultDraw ||
      NoMercyRunDto.resultWin => value as String,
      _ => invalid('resultType', value),
    };
  }

  static Never invalid(String field, Object? value) {
    throw FormatException('Invalid No Mercy run field "$field".', value);
  }

  static void _validateMoveHistory(NoMercyRunDto run, Board board) {
    final occupiedMoves = <int>{};
    for (final move in [...run.humanMoves, ...run.cpuMoves]) {
      if (!occupiedMoves.add(move)) {
        invalid('moves', move);
      }
    }

    for (final move in run.humanMoves) {
      if (board.markAt(move) != Mark.x) {
        invalid('humanMoves', run.humanMoves);
      }
    }

    for (final move in run.cpuMoves) {
      if (board.markAt(move) != Mark.o) {
        invalid('cpuMoves', run.cpuMoves);
      }
    }

    for (var index = 0; index < Board.cellCount; index++) {
      final mark = board.markAt(index);
      if (mark == Mark.x && !run.humanMoves.contains(index)) {
        invalid('humanMoves', run.humanMoves);
      }
      if (mark == Mark.o && !run.cpuMoves.contains(index)) {
        invalid('cpuMoves', run.cpuMoves);
      }
    }

    if (run.humanMoves.length != run.cpuMoves.length &&
        run.humanMoves.length != run.cpuMoves.length + 1) {
      invalid('moves', {
        'humanMoves': run.humanMoves,
        'cpuMoves': run.cpuMoves,
      });
    }
  }

  static void _validateCurrentMark(NoMercyRunDto run, Mark current) {
    if (run.resultType != NoMercyRunDto.resultOngoing) {
      return;
    }

    final expected = run.humanMoves.length == run.cpuMoves.length
        ? Mark.x
        : Mark.o;
    if (current != expected) {
      invalid('currentMark', run.currentMark);
    }
  }

  static void _validateResult(NoMercyRunDto run, Board board) {
    if (run.resultType != NoMercyRunDto.resultWin && run.winner != null) {
      invalid('winner', run.winner);
    }
    if (run.resultType != NoMercyRunDto.resultWin &&
        run.winningCells.isNotEmpty) {
      invalid('winningCells', run.winningCells);
    }
    if (run.resultType == NoMercyRunDto.resultWin && run.winner == null) {
      invalid('winner', run.winner);
    }

    final stored = NoMercyRunDtoMapper.result(run, board);
    final evaluated = const GameRules().evaluate(board);
    if (!_sameResult(stored, evaluated)) {
      invalid('result', {
        'resultType': run.resultType,
        'winner': run.winner,
        'winningCells': run.winningCells,
      });
    }
  }

  static bool _sameResult(GameResult first, GameResult second) {
    return switch ((first, second)) {
      (GameOngoing(), GameOngoing()) => true,
      (GameDraw(), GameDraw()) => true,
      (
        GameWin(winner: final firstWinner, winningCells: final firstCells),
        GameWin(winner: final secondWinner, winningCells: final secondCells),
      ) =>
        firstWinner == secondWinner && _sameCells(firstCells, secondCells),
      _ => false,
    };
  }

  static bool _sameCells(List<int> first, List<int> second) {
    if (first.length != second.length) {
      return false;
    }

    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }

    return true;
  }
}
