import 'package:flutter/material.dart';

import 'package:tictactoe/core/assets/app_assets.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/presentation/dialogs/action_dialog.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';

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
    final copy = GameCopy.of(context);

    return showActionDialog<GameOverChoice>(
      context: context,
      barrierLabel: copy.gameOverTitle,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(result: result, mode: mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = GameCopy.of(context);
    final message = switch (result) {
      GameWin(:final winner) => copy.winDialogTitle(winner, mode),
      GameDraw() => copy.drawDialogTitle,
      GameOngoing() => copy.gameTitle,
    };

    return ActionDialog(
      title: copy.gameOverTitle,
      message: message,
      leadingArt: _ResultGlyph(result: result, mode: mode),
      actions: [
        ActionDialogButton(
          label: copy.goHomeAction,
          onPressed: () => Navigator.of(context).pop(GameOverChoice.home),
        ),
        ActionDialogButton(
          label: copy.playAgainAction,
          prominent: true,
          onPressed: () => Navigator.of(context).pop(GameOverChoice.playAgain),
        ),
      ],
    );
  }
}

class _ResultGlyph extends StatelessWidget {
  const _ResultGlyph({required this.result, required this.mode});

  final GameResult result;
  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    final asset = _assetFor(result);
    final tint = _tintFor(result, mode);

    return SizedBox.square(
      dimension: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    tint.withValues(alpha: AppAlphas.muted),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Image.asset(
            asset,
            width: 44,
            height: 44,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            opacity: AlwaysStoppedAnimation(_iconOpacityFor(result, mode)),
            excludeFromSemantics: true,
          ),
        ],
      ),
    );
  }

  String _assetFor(GameResult result) {
    return switch (result) {
      GameWin(:final winner) =>
        winner == Player.human ? AppAssets.flask : AppAssets.runeArc,
      GameDraw() => AppAssets.statusRune,
      GameOngoing() => AppAssets.statusRune,
    };
  }

  Color _tintFor(GameResult result, GameMode mode) {
    return switch (result) {
      GameWin(:final winner) =>
        winner == Player.human || mode != GameMode.humanVsCpu
            ? AppPalette.goldBright
            : AppPalette.lossRed,
      _ => AppPalette.gold,
    };
  }

  double _iconOpacityFor(GameResult result, GameMode mode) {
    return switch (result) {
      GameWin(:final winner)
          when winner == Player.cpu && mode == GameMode.humanVsCpu =>
        AppAlphas.medium,
      _ => AppAlphas.opaque,
    };
  }
}
