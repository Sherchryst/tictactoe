import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_gradients.dart';
import 'package:tictactoe/core/design_system/tokens/app_shadows.dart';
import 'package:tictactoe/core/design_system/widgets/chrome_corner_flourish.dart';
import 'package:tictactoe/core/design_system/widgets/sigil_backdrop.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_view_state.dart';
import 'package:tictactoe/features/game/presentation/utils/rendering/board_grid_painter.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_board_cell.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_board_effects.dart'
    as board_effects;

class GameBoard extends HookWidget {
  const GameBoard({
    required this.session,
    required this.phase,
    required this.onCellPressed,
    super.key,
  });

  final GameSession session;
  final GameViewPhase phase;
  final ValueChanged<int> onCellPressed;

  @override
  Widget build(BuildContext context) {
    final tapLocked = useRef(false);
    final board = session.board;
    final result = session.result;
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
      child: board_effects.GameBoardDrawShake(
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

                      return GameBoardCell(
                        mark: board.markAt(index),
                        session: session,
                        highlighted: winningCells.contains(index),
                        enabled:
                            phase == GameViewPhase.awaitingHumanMove &&
                            session.canHumanPlay &&
                            canPlace,
                        onPressed: () => handleCellPressed(index),
                      );
                    },
                  ),
                  if (winningCells.isNotEmpty && winWinner != null)
                    board_effects.GameBoardWinningBeam(
                      winningCells: winningCells,
                      winner: winWinner,
                    ),
                  if (result is GameDraw)
                    const board_effects.GameBoardDrawFog(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
