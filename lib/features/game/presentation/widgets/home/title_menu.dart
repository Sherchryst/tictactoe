import 'package:flutter/material.dart';

import 'package:tictactoe/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/home_menu_action.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/title_menu_item.dart';

class TitleMenu extends StatelessWidget {
  const TitleMenu({
    required this.copy,
    required this.selectedAction,
    required this.pressedAction,
    required this.onSelected,
    super.key,
  });

  static const double itemHeight = AppSpacing.xxxl;
  static const double gap = AppSpacing.xs;
  static const double totalHeight = itemHeight * 3 + gap * 2;

  final GameCopy copy;
  final HomeMenuAction selectedAction;
  final HomeMenuAction? pressedAction;
  final ValueChanged<HomeMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
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
            _itemFor(HomeMenuAction.duel, copy.localGameAction),
            const SizedBox(height: gap),
            _itemFor(HomeMenuAction.solo, copy.aiGameAction),
            const SizedBox(height: gap),
            _itemFor(HomeMenuAction.system, copy.settingsTitle),
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
