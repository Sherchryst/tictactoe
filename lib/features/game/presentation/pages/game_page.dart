import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/widgets/page_frame.dart';
import '../../domain/entities/game_mode.dart';
import '../../domain/entities/player.dart';
import '../controllers/game_controller.dart';
import '../dialogs/game_over_dialog.dart';
import '../game_copy.dart';
import '../widgets/game_board.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);

    ref.listen(gameControllerProvider, (previous, next) {
      final result = next.session.result;
      if (result.isOngoing || previous?.session.result == result) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) {
          return;
        }

        final choice = await GameOverDialog.show(
          context: context,
          result: result,
          mode: next.session.mode,
        );

        if (choice == GameOverChoice.playAgain) {
          ref.read(gameControllerProvider.notifier).startNewRound();
        } else if (choice == GameOverChoice.home && context.mounted) {
          context.go(AppRoutes.homeLocation);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(GameCopy.gameModeTitle(game.session.mode)),
        leading: IconButton(
          tooltip: GameCopy.homeTooltip,
          onPressed: () => context.go(AppRoutes.homeLocation),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: PageFrame(
        maxWidth: 520,
        child: Column(
          children: [
            _TurnHeader(
              mode: game.session.mode,
              currentPlayer: game.session.currentPlayer,
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Center(
                child: GameBoard(
                  board: game.session.board,
                  result: game.session.result,
                  onCellPressed: ref
                      .read(gameControllerProvider.notifier)
                      .playCell,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TurnHeader extends StatelessWidget {
  const _TurnHeader({required this.mode, required this.currentPlayer});

  final GameMode mode;
  final Player currentPlayer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlayerBadge(
            label: GameCopy.scoreLabelFor(Player.human, mode),
            selected: currentPlayer == Player.human,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            GameCopy.vsLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: _PlayerBadge(
            label: GameCopy.scoreLabelFor(Player.cpu, mode),
            selected: currentPlayer == Player.cpu,
          ),
        ),
      ],
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  const _PlayerBadge({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: selected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
