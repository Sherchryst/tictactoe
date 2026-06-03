import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/audio/domain/entities/menu_sfx.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/design_system/widgets/action_dialog.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/presentation/utils/text/player_label_resolver.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

enum GameOverChoice { playAgain, home }

class GameOverDialog extends ConsumerWidget {
  const GameOverDialog({required this.result, required this.mode, super.key});

  final GameResult result;
  final GameMode mode;

  static Future<GameOverChoice?> show({
    required BuildContext context,
    required GameResult result,
    required GameMode mode,
  }) {
    final l10n = AppLocalizations.of(context);

    return showActionDialog<GameOverChoice>(
      context: context,
      barrierLabel: l10n.gameOverTitle,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(result: result, mode: mode),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playerLabels = PlayerLabelResolver(l10n);
    final message = switch (result) {
      GameWin(:final winner) => playerLabels.win(winner, mode),
      GameDraw() => l10n.drawDialogTitle,
      GameOngoing() => l10n.gameTitle,
    };

    return ActionDialog(
      title: l10n.gameOverTitle,
      message: message,
      leadingArt: _ResultGlyph(result: result, mode: mode),
      onActionFeedback: () {
        unawaited(
          ref.read(audioControllerProvider).playMenuSfx(MenuSfx.select),
        );
      },
      actions: [
        ActionDialogButton(
          label: l10n.goHomeAction,
          onPressed: () => Navigator.of(context).pop(GameOverChoice.home),
        ),
        ActionDialogButton(
          label: l10n.playAgainAction,
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
