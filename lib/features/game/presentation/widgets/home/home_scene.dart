import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/widgets/sigil_backdrop.dart';
import 'package:tictactoe/core/design_system/widgets/tic_tac_toe_title_logo.dart';
import 'package:tictactoe/core/router/hero_tags.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/home_entrance.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/home_menu_action.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/title_menu.dart';

class HomeScene extends StatelessWidget {
  const HomeScene({
    required this.title,
    required this.entrance,
    required this.selectedAction,
    required this.onSelected,
    required this.showContinue,
    required this.showCredits,
    this.pressedAction,
    super.key,
  });

  final String title;
  final Animation<double> entrance;
  final HomeMenuAction selectedAction;
  final HomeMenuAction? pressedAction;
  final ValueChanged<HomeMenuAction> onSelected;
  final bool showContinue;
  final bool showCredits;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final logoTop = screen.height * 0.15;
    final logoSideInset = (screen.shortestSide * 0.11)
        .clamp(38.0, 54.0)
        .toDouble();
    final logoFontSize = (screen.shortestSide * 0.15)
        .clamp(52.0, 64.0)
        .toDouble();
    final sigilSize = (screen.shortestSide * 1.18)
        .clamp(410.0, 540.0)
        .toDouble();
    final sigilTop = screen.height * 0.17;
    final menuTop = screen.height * 0.43;

    return Scaffold(
      body: ColoredBox(
        color: AppPalette.backgroundDeep,
        child: Stack(
          children: [
            Positioned(
              top: sigilTop,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.36,
                  child: SigilBackdrop(height: sigilSize),
                ),
              ),
            ),
            Positioned(
              top: logoTop,
              left: logoSideInset,
              right: logoSideInset,
              child: Hero(
                tag: HeroTags.titleLogo,
                child: TicTacToeTitleLogo(title: title, fontSize: logoFontSize),
              ),
            ),
            Positioned(
              top: menuTop,
              left: 0,
              right: 0,
              height: TitleMenu.totalHeightFor(
                showContinue: showContinue,
                showCredits: showCredits,
              ),
              child: HomeEntrance(
                animation: entrance,
                begin: 0.34,
                end: 0.92,
                offset: const Offset(0, 24),
                child: TitleMenu(
                  selectedAction: selectedAction,
                  pressedAction: pressedAction,
                  onSelected: onSelected,
                  showContinue: showContinue,
                  showCredits: showCredits,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
