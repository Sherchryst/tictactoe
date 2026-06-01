import 'package:flutter/material.dart';

import '../../domain/entities/board.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_result.dart';
import '../game_copy.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.board,
    required this.result,
    required this.onCellPressed,
    super.key,
  });

  final Board board;
  final GameResult result;
  final ValueChanged<int> onCellPressed;

  @override
  Widget build(BuildContext context) {
    final winningCells = switch (result) {
      GameWin(:final winningCells) => winningCells,
      _ => const <int>[],
    };

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Board.size,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: Board.cellCount,
        itemBuilder: (context, index) {
          return _GameCell(
            cell: board.cellAt(index),
            highlighted: winningCells.contains(index),
            enabled: result.isOngoing && board.canPlace(index),
            onPressed: () => onCellPressed(index),
          );
        },
      ),
    );
  }
}

class _GameCell extends StatelessWidget {
  const _GameCell({
    required this.cell,
    required this.highlighted,
    required this.enabled,
    required this.onPressed,
  });

  final Cell cell;
  final bool highlighted;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mark = GameCopy.markFor(cell);

    return Material(
      color: highlighted
          ? colorScheme.tertiaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            mark,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cell == Cell.human
                  ? colorScheme.primary
                  : colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
