import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/audio/domain/entities/menu_sfx.dart';
import 'package:tictactoe/core/design_system/widgets/action_dialog.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class ResetNoMercyRunDialog extends ConsumerWidget {
  const ResetNoMercyRunDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showActionDialog<bool>(
      context: context,
      barrierLabel: l10n.resetRunTitle,
      builder: (context) => const ResetNoMercyRunDialog(),
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ActionDialog(
      title: l10n.resetRunTitle,
      message: l10n.resetRunMessage,
      onActionFeedback: () {
        unawaited(
          ref.read(audioControllerProvider).playMenuSfx(MenuSfx.select),
        );
      },
      actions: [
        ActionDialogButton(
          label: l10n.backTooltip,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ActionDialogButton(
          label: l10n.noMercyAction,
          prominent: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
