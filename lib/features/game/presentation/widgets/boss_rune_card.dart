import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/features/game/presentation/utils/bosses/boss_glow_palette.dart';

class BossRuneCard extends StatelessWidget {
  const BossRuneCard({
    required this.asset,
    required this.prominent,
    required this.hostile,
    this.opacity = 1,
    this.pulse = 0,
    this.revealProgress = 0,
    this.shineProgress = 0,
    this.glowPalette = BossGlowPalette.guided,
    this.deadAsset,
    this.deadProgress = 0,
    this.deadOpacityKey,
    this.shineKey,
    super.key,
  });

  final String asset;
  final String? deadAsset;
  final bool prominent;
  final bool hostile;
  final double opacity;
  final double pulse;
  final double revealProgress;
  final double shineProgress;
  final BossGlowPalette glowPalette;
  final double deadProgress;
  final Key? deadOpacityKey;
  final Key? shineKey;

  @override
  Widget build(BuildContext context) {
    final reveal = revealProgress.clamp(0.0, 1.0);
    final baseColor = hostile
        ? Color.lerp(glowPalette.edge, AppPalette.backgroundDeep, 0.68)!
        : AppPalette.surfaceRaised;
    final accentColor = hostile ? glowPalette.primary : AppPalette.gold;
    final secondaryColor = hostile ? glowPalette.secondary : AppPalette.gold;
    final coreColor = hostile ? glowPalette.core : AppPalette.ivoryText;
    final particleColor = hostile
        ? glowPalette.particle
        : AppPalette.goldBright;
    final baseAlpha = prominent ? AppAlphas.medium : AppAlphas.subtle;
    final cardBackgroundAlpha = hostile
        ? (prominent ? 0.98 : 0.92)
        : 0.72 * reveal;
    final cardTintAlpha = hostile ? (prominent ? 0.08 : 0.04) : baseAlpha;
    final runeBackdropAlpha = hostile ? (prominent ? 0.76 : 0.64) : 0.0;
    final borderAlpha = prominent ? AppAlphas.prominent : AppAlphas.muted;
    final borderWidth = prominent ? 1.4 : 1.0;
    final imageOpacity = prominent ? 1.0 : 0.6;
    final dead = deadProgress.clamp(0.0, 1.0);
    final aliveImageOpacity = deadAsset == null
        ? imageOpacity
        : imageOpacity * (1 - dead);
    final radius = 6.0 + reveal * 2.0;
    final padding = 4.0 + reveal * 3.0;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: 1 + pulse * 0.08 * reveal,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    particleColor.withValues(
                      alpha: (0.18 + pulse * 0.12) * reveal,
                    ),
                    accentColor.withValues(alpha: 0.14 * reveal),
                    secondaryColor.withValues(alpha: 0.1 * reveal),
                    const Color(0x00000000),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  color: AppPalette.backgroundDeep.withValues(
                    alpha: cardBackgroundAlpha,
                  ),
                  gradient: RadialGradient(
                    colors: [
                      baseColor.withValues(alpha: cardTintAlpha),
                      const Color(0x00000000),
                    ],
                  ),
                  border: Border.all(
                    color: accentColor.withValues(alpha: borderAlpha),
                    width: borderWidth,
                  ),
                  boxShadow: prominent
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(
                              alpha: AppAlphas.medium,
                            ),
                            blurRadius: hostile ? 18 + reveal * 12 : 14,
                            spreadRadius: hostile ? 1 + reveal : 0,
                          ),
                          if (reveal > 0)
                            BoxShadow(
                              color: particleColor.withValues(
                                alpha: 0.22 * reveal,
                              ),
                              blurRadius: 20,
                            ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    (radius - 1).clamp(0.0, radius),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        key: shineKey,
                        opacity: shineProgress * reveal,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                coreColor.withValues(alpha: 0.1),
                                particleColor.withValues(alpha: 0.045),
                                const Color(0x00000000),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (runeBackdropAlpha > 0)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                AppPalette.backgroundDeep.withValues(
                                  alpha: runeBackdropAlpha * 0.9,
                                ),
                                AppPalette.backgroundDeep.withValues(
                                  alpha: runeBackdropAlpha,
                                ),
                              ],
                            ),
                          ),
                        ),
                      Image.asset(
                        asset,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        excludeFromSemantics: true,
                        opacity: AlwaysStoppedAnimation(aliveImageOpacity),
                      ),
                      if (deadAsset != null && dead > 0)
                        Opacity(
                          key: deadOpacityKey,
                          opacity: dead,
                          child: Image.asset(
                            deadAsset!,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            excludeFromSemantics: true,
                            opacity: AlwaysStoppedAnimation(imageOpacity),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
