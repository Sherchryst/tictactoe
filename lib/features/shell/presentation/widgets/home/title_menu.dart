import 'package:flutter/material.dart';

import 'package:tictactoe/core/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/features/shell/presentation/widgets/home/home_menu_action.dart';
import 'package:tictactoe/features/shell/presentation/widgets/home/title_menu_item.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class TitleMenu extends StatelessWidget {
  const TitleMenu({
    required this.selectedAction,
    required this.pressedAction,
    required this.onSelected,
    super.key,
  });

  static const double itemHeight = AppSpacing.xxxl;
  static const double gap = AppSpacing.xs;
  static const double totalHeight = itemHeight * 4 + gap * 3;

  final HomeMenuAction selectedAction;
  final HomeMenuAction? pressedAction;
  final ValueChanged<HomeMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final itemWidth = (MediaQuery.sizeOf(context).shortestSide * 0.56)
        .clamp(206.0, 242.0)
        .toDouble();

    return Center(
      child: SizedBox(
        width: itemWidth,
        height: totalHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _itemFor(HomeMenuAction.duel, l10n.localGameAction),
            const SizedBox(height: gap),
            _itemFor(HomeMenuAction.solo, l10n.aiGameAction),
            const SizedBox(height: gap),
            _itemFor(HomeMenuAction.score, l10n.scoreTitle),
            const SizedBox(height: gap),
            _itemFor(HomeMenuAction.system, l10n.settingsTitle),
          ],
        ),
      ),
    );
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
