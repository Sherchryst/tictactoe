import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';

class WinningBeamPalette {
  const WinningBeamPalette({
    required this.bright,
    required this.mid,
    required this.dim,
    required this.halo,
    required this.core,
  });

  factory WinningBeamPalette.forWinner(Mark winner) {
    return switch (winner) {
      Mark.x => const WinningBeamPalette(
        bright: AppPalette.goldBright,
        mid: AppPalette.gold,
        dim: AppPalette.goldDim,
        halo: AppPalette.gold,
        core: AppPalette.ivoryText,
      ),
      Mark.o => const WinningBeamPalette(
        bright: Color(0xffd8323d),
        mid: AppPalette.lossRed,
        dim: AppPalette.lossRedDeep,
        halo: AppPalette.lossRed,
        core: Color(0xffffc0a8),
      ),
    };
  }

  final Color bright;
  final Color mid;
  final Color dim;
  final Color halo;
  final Color core;
}
