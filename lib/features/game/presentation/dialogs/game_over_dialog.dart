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
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/participant.dart';
import 'package:tictactoe/features/game/presentation/utils/bosses/boss_presentation.dart';
import 'package:tictactoe/features/game/presentation/utils/text/player_label_resolver.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

enum GameOverChoice { playAgain, home, nextBoss, newGamePlus, titleScreen }

class GameOverDialog extends ConsumerWidget {
  const GameOverDialog({required this.session, super.key});

  final GameSession session;

  static Future<GameOverChoice?> show({
    required BuildContext context,
    required GameSession session,
  }) {
    final l10n = AppLocalizations.of(context);

    return showActionDialog<GameOverChoice>(
      context: context,
      barrierLabel: l10n.gameOverTitle,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(session: session),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playerLabels = PlayerLabelResolver(l10n);
    final message = playerLabels.result(session);

    return ActionDialog(
      title: l10n.gameOverTitle,
      message: message,
      leadingArt: _ResultGlyph(session: session),
      onActionFeedback: () {
        unawaited(
          ref.read(audioControllerProvider).playMenuSfx(MenuSfx.select),
        );
      },
      actions: _actions(context, l10n),
    );
  }

  List<ActionDialogButton> _actions(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (session.defeatedNoMercyFinalBoss) {
      return [
        ActionDialogButton(
          label: l10n.newGamePlusAction,
          prominent: true,
          onPressed: () =>
              Navigator.of(context).pop(GameOverChoice.newGamePlus),
        ),
        ActionDialogButton(
          label: l10n.goHomeAction,
          onPressed: () =>
              Navigator.of(context).pop(GameOverChoice.titleScreen),
        ),
      ];
    }

    final roundAction = _roundAction(context, l10n);

    return [
      ActionDialogButton(
        label: l10n.goHomeAction,
        onPressed: () => Navigator.of(context).pop(GameOverChoice.home),
      ),
      ?roundAction,
    ];
  }

  ActionDialogButton? _roundAction(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (session.canAdvanceToNextNoMercyBoss) {
      return ActionDialogButton(
        label: l10n.nextBossAction,
        prominent: true,
        onPressed: () => Navigator.of(context).pop(GameOverChoice.nextBoss),
      );
    }

    if (session.isNoMercy &&
        session.participantOutcome == GameOutcome.humanWin) {
      return null;
    }

    return ActionDialogButton(
      label: l10n.playAgainAction,
      prominent: true,
      onPressed: () => Navigator.of(context).pop(GameOverChoice.playAgain),
    );
  }
}

class _ResultGlyph extends StatelessWidget {
  const _ResultGlyph({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final asset = _assetFor(session);
    final tint = _tintFor(session);

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
            opacity: AlwaysStoppedAnimation(_iconOpacityFor(session)),
            excludeFromSemantics: true,
          ),
        ],
      ),
    );
  }

  String _assetFor(GameSession session) {
    return switch (session.result) {
      GameWin(:final winner) => switch (session.participantFor(winner)) {
        CpuParticipant(:final bossId) => bossId.presentation.aliveAsset,
        HumanParticipant() when session.mode == GameMode.noMercyRun =>
          session.bossId.presentation.deadAsset,
        HumanParticipant(:final mark) =>
          mark == session.humanMark ? AppAssets.flask : AppAssets.runeArc,
      },
      GameDraw() => AppAssets.statusRune,
      GameOngoing() => AppAssets.statusRune,
    };
  }

  Color _tintFor(GameSession session) {
    return switch (session.result) {
      GameWin() =>
        session.mode == GameMode.localDuel ||
                session.participantOutcome == GameOutcome.humanWin
            ? AppPalette.goldBright
            : AppPalette.lossRed,
      _ => AppPalette.gold,
    };
  }

  double _iconOpacityFor(GameSession session) {
    return switch (session.result) {
      GameWin()
          when session.mode != GameMode.localDuel &&
              session.participantOutcome == GameOutcome.cpuWin =>
        AppAlphas.medium,
      _ => AppAlphas.opaque,
    };
  }
}
