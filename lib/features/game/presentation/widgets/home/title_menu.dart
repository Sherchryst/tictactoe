import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/home_menu_action.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/title_menu_item.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class TitleMenu extends StatelessWidget {
  const TitleMenu({
    required this.selectedAction,
    required this.pressedAction,
    required this.onSelected,
    required this.showContinue,
    required this.showCredits,
    super.key,
  });

  static const double itemHeight = AppSpacing.xxxl;
  static const double gap = AppSpacing.xs;

  final HomeMenuAction selectedAction;
  final HomeMenuAction? pressedAction;
  final ValueChanged<HomeMenuAction> onSelected;
  final bool showContinue;
  final bool showCredits;

  static double totalHeightFor({
    required bool showContinue,
    required bool showCredits,
  }) {
    final itemCount = homeMenuActionsFor(
      showContinue: showContinue,
      showCredits: showCredits,
    ).length;
    return itemHeight * itemCount + gap * (itemCount - 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = homeMenuActionsFor(
      showContinue: showContinue,
      showCredits: showCredits,
    );
    final itemWidth = (MediaQuery.sizeOf(context).shortestSide * 0.56)
        .clamp(206.0, 242.0)
        .toDouble();

    return Center(
      child: SizedBox(
        width: itemWidth,
        height: totalHeightFor(
          showContinue: showContinue,
          showCredits: showCredits,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in actions.indexed) ...[
              _itemFor(entry.$2, _labelFor(l10n, entry.$2)),
              if (entry.$1 < actions.length - 1) const SizedBox(height: gap),
            ],
          ],
        ),
      ),
    );
  }

  String _labelFor(AppLocalizations l10n, HomeMenuAction action) {
    return switch (action) {
      HomeMenuAction.continueRun => l10n.continueRunAction,
      HomeMenuAction.solo => l10n.aiGameAction,
      HomeMenuAction.duel => l10n.localGameAction,
      HomeMenuAction.score => l10n.scoreTitle,
      HomeMenuAction.system => l10n.settingsTitle,
      HomeMenuAction.credits => l10n.creditsBarrierLabel,
    };
  }

  Widget _itemFor(HomeMenuAction action, String label) {
    return TitleMenuItem(
      action: action,
      label: label,
      selected: selectedAction == action,
      pressed: pressedAction == action,
      onPressed: () => onSelected(action),
      itemHeight: itemHeight,
    );
  }
}
