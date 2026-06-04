import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/widgets/action_dialog.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

final class ScoreResetConfirmationResult {
  const ScoreResetConfirmationResult({required this.doNotAskAgain});

  final bool doNotAskAgain;
}

Future<ScoreResetConfirmationResult?> showScoreResetConfirmationDialog({
  required BuildContext context,
}) {
  final l10n = AppLocalizations.of(context);

  return showActionDialog<ScoreResetConfirmationResult>(
    context: context,
    barrierLabel: l10n.resetScoreConfirmTitle,
    builder: (context) => const ScoreResetConfirmationDialog(),
  );
}

class ScoreResetConfirmationDialog extends StatefulWidget {
  const ScoreResetConfirmationDialog({super.key});

  @override
  State<ScoreResetConfirmationDialog> createState() =>
      _ScoreResetConfirmationDialogState();
}

class _ScoreResetConfirmationDialogState
    extends State<ScoreResetConfirmationDialog> {
  var _doNotAskAgain = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ActionDialog(
      title: l10n.resetScoreConfirmTitle,
      message: l10n.resetScoreConfirmMessage,
      content: _DoNotAskToggle(
        value: _doNotAskAgain,
        onChanged: (value) => setState(() => _doNotAskAgain = value),
      ),
      actions: [
        ActionDialogButton(
          label: l10n.backTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
        ActionDialogButton(
          label: l10n.resetScoreConfirmAction,
          prominent: true,
          onPressed: () {
            Navigator.of(
              context,
            ).pop(ScoreResetConfirmationResult(doNotAskAgain: _doNotAskAgain));
          },
        ),
      ],
    );
  }
}

class _DoNotAskToggle extends StatelessWidget {
  const _DoNotAskToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (next) => onChanged(next ?? false),
            activeColor: AppPalette.goldBright,
            checkColor: AppPalette.backgroundDeep,
            side: BorderSide(
              color: AppPalette.ivoryText.withValues(alpha: AppAlphas.medium),
            ),
          ),
          Expanded(
            child: Text(
              l10n.resetScoreDontAskAgain,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppPalette.ivoryText.withValues(alpha: 0.78),
                fontFamily: AppPalette.serifFont,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
