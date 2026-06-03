import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/core/design_system/tokens/app_gradients.dart';
import 'package:tictactoe/core/design_system/tokens/app_shadows.dart';
import 'package:tictactoe/core/design_system/widgets/app_haptics.dart';
import 'package:tictactoe/core/design_system/widgets/chrome_corner_flourish.dart';
import 'package:tictactoe/core/design_system/widgets/sigil_backdrop.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/presentation/utils/rendering/game_board_painters.dart';

part 'game_board_cell.dart';
part 'game_board_effects.dart';

class GameBoard extends HookWidget {
  const GameBoard({
    required this.board,
    required this.result,
    required this.onCellPressed,
    required this.mode,
    super.key,
  });

  final Board board;
  final GameResult result;
  final ValueChanged<int> onCellPressed;
  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    final tapLocked = useRef(false);
    final winningCells = switch (result) {
      GameWin(:final winningCells) => winningCells,
      _ => const <int>[],
    };
    final winWinner = switch (result) {
      GameWin(:final winner) => winner,
      _ => null,
    };
    final compact = MediaQuery.sizeOf(context).shortestSide < 560;
    final framePadding = compact ? 10.0 : 14.0;

    void handleCellPressed(int index) {
      if (tapLocked.value) {
        return;
      }

      tapLocked.value = true;
      onCellPressed(index);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tapLocked.value = false;
      });
    }

    return RepaintBoundary(
      child: _DrawShake(
        enabled: result is GameDraw,
        child: AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppGradients.boardSurface(),
              border: Border.all(
                color: AppPalette.gold.withValues(alpha: AppAlphas.faint),
              ),
              boxShadow: AppShadows.board(),
            ),
            child: Padding(
              padding: EdgeInsets.all(framePadding),
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.13,
                        child: Padding(
                          padding: EdgeInsets.all(framePadding * 1.8),
                          child: const SigilBackdrop(),
                        ),
                      ),
                    ),
                  ),
                  RepaintBoundary(
                    child: CustomPaint(
                      isComplex: true,
                      painter: BoardGridPainter(),
                    ),
                  ),
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: ChromeCornerFlourish(extent: 20),
                    ),
                  ),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: Board.size,
                        ),
                    itemCount: Board.cellCount,
                    itemBuilder: (context, index) {
                      final canPlace = board.canPlace(index);

                      return _GameCell(
                        cell: board.cellAt(index),
                        mode: mode,
                        highlighted: winningCells.contains(index),
                        enabled: result.isOngoing && canPlace,
                        onPressed: () => handleCellPressed(index),
                      );
                    },
                  ),
                  if (winningCells.isNotEmpty && winWinner != null)
                    _WinningBeam(winningCells: winningCells, winner: winWinner),
                  if (result is GameDraw) const _DrawFog(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
