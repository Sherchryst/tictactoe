import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/audio/domain/entities/menu_sfx.dart';
import 'package:tictactoe/core/design_system/widgets/action_dialog.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/features/shell/presentation/models/solo_challenge.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class DifficultyDialog extends ConsumerWidget {
  const DifficultyDialog({super.key});

  static Future<SoloChallenge?> show(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return showActionDialog<SoloChallenge>(
      context: context,
      barrierLabel: l10n.selectDifficultyTitle,
      builder: (context) => const DifficultyDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ActionDialog(
      title: l10n.selectDifficultyTitle,
      message: l10n.selectDifficultyMessage,
      onActionFeedback: () {
        unawaited(
          ref.read(audioControllerProvider).playMenuSfx(MenuSfx.select),
        );
      },
      actions: [
        ActionDialogButton(
          label: l10n.easyLabel,
          onPressed: () => Navigator.of(context).pop(SoloChallenge.guided),
        ),
        ActionDialogButton(
          label: l10n.hardLabel,
          prominent: true,
          onPressed: () => Navigator.of(context).pop(SoloChallenge.noMercy),
        ),
      ],
    );
  }
}
