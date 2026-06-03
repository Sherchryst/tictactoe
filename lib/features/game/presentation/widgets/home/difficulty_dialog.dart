import 'package:flutter/material.dart';

import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/presentation/dialogs/action_dialog.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';

class DifficultyDialog extends StatelessWidget {
  const DifficultyDialog({super.key});

  static Future<GameDifficulty?> show(BuildContext context) {
    final copy = GameCopy.of(context);

    return showActionDialog<GameDifficulty>(
      context: context,
      barrierLabel: copy.selectDifficultyTitle,
      builder: (context) => const DifficultyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = GameCopy.of(context);

    return ActionDialog(
      title: copy.selectDifficultyTitle,
      message: copy.selectDifficultyMessage,
      actions: [
        ActionDialogButton(
          label: copy.easyLabel,
          onPressed: () => Navigator.of(context).pop(GameDifficulty.easy),
        ),
        ActionDialogButton(
          label: copy.hardLabel,
          prominent: true,
          onPressed: () => Navigator.of(context).pop(GameDifficulty.hard),
        ),
      ],
    );
  }
}
