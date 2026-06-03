import 'dart:math';

import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/game_domain_messages.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';

final class RandomCpuStrategy implements CpuStrategy {
  RandomCpuStrategy({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  int chooseMove(Board board, Player player) {
    final emptyCells = board.emptyCells;
    if (emptyCells.isEmpty) {
      throw StateError(GameDomainMessages.noMoveAvailable);
    }

    return emptyCells[_random.nextInt(emptyCells.length)];
  }
}
