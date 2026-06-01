import 'package:flutter/material.dart';

import '../../../../core/ui/widgets/action_dialog.dart';
import '../../domain/entities/game_mode.dart';
import '../../domain/entities/game_result.dart';
import '../game_copy.dart';

enum GameOverChoice { playAgain, home }

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({required this.result, required this.mode, super.key});

  final GameResult result;
  final GameMode mode;

  static Future<GameOverChoice?> show({
    required BuildContext context,
    required GameResult result,
    required GameMode mode,
  }) {
    return showDialog<GameOverChoice>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(result: result, mode: mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = switch (result) {
      GameWin(:final winner) => GameCopy.winDialogTitle(winner, mode),
      GameDraw() => GameCopy.drawDialogTitle,
      GameOngoing() => GameCopy.gameTitle,
    };

    return ActionDialog(
      title: GameCopy.gameOverTitle,
      message: message,
      actions: [
        ActionDialogButton(
          label: GameCopy.goHomeAction,
          onPressed: () => Navigator.of(context).pop(GameOverChoice.home),
        ),
        ActionDialogButton(
          label: GameCopy.playAgainAction,
          prominent: true,
          onPressed: () => Navigator.of(context).pop(GameOverChoice.playAgain),
        ),
      ],
    );
  }
}
