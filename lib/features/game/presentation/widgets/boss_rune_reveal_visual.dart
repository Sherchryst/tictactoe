import 'package:flutter/material.dart';
import 'package:tictactoe/features/game/presentation/utils/bosses/boss_glow_palette.dart';
import 'package:tictactoe/features/game/presentation/widgets/boss_rune_card.dart';

class BossRuneRevealVisual extends StatelessWidget {
  const BossRuneRevealVisual({
    required this.asset,
    required this.shineProgress,
    required this.opacity,
    required this.pulse,
    required this.revealProgress,
    this.glowPalette = BossGlowPalette.guided,
    this.deadAsset,
    this.deadProgress = 0,
    this.deadOpacityKey,
    this.shineKey,
    super.key,
  });

  final String asset;
  final String? deadAsset;
  final double shineProgress;
  final double deadProgress;
  final double opacity;
  final double pulse;
  final double revealProgress;
  final BossGlowPalette glowPalette;
  final Key? deadOpacityKey;
  final Key? shineKey;

  @override
  Widget build(BuildContext context) {
    return BossRuneCard(
      asset: asset,
      prominent: true,
      hostile: true,
      opacity: opacity,
      pulse: pulse,
      revealProgress: revealProgress,
      glowPalette: glowPalette,
      shineProgress: shineProgress,
      deadAsset: deadAsset,
      deadProgress: deadProgress,
      deadOpacityKey: deadOpacityKey,
      shineKey: shineKey,
    );
  }
}
