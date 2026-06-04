import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/presentation/utils/bosses/boss_glow_palette.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

final class BossPresentation {
  const BossPresentation({
    required this.id,
    required this.emblemAsset,
    required this.aliveAsset,
    required this.deadAsset,
    required this.glowPalette,
  });

  final CpuBossId id;
  final String emblemAsset;
  final String aliveAsset;
  final String deadAsset;
  final BossGlowPalette glowPalette;

  String name(AppLocalizations l10n) {
    return switch (id) {
      CpuBossId.guided => l10n.cpuTurnStatus,
      CpuBossId.radahn => l10n.bossRadahnName,
      CpuBossId.mohg => l10n.bossMohgName,
      CpuBossId.malenia => l10n.bossMaleniaName,
    };
  }
}

extension CpuBossPresentation on CpuBossId {
  BossPresentation get presentation {
    return switch (this) {
      CpuBossId.guided => const BossPresentation(
        id: CpuBossId.guided,
        emblemAsset: AppAssets.runeArc,
        aliveAsset: AppAssets.runeArc,
        deadAsset: AppAssets.runeArc,
        glowPalette: BossGlowPalette.guided,
      ),
      CpuBossId.radahn => const BossPresentation(
        id: CpuBossId.radahn,
        emblemAsset: AppAssets.radahn,
        aliveAsset: AppAssets.radahn,
        deadAsset: AppAssets.radahnDead,
        glowPalette: BossGlowPalette.radahn,
      ),
      CpuBossId.mohg => const BossPresentation(
        id: CpuBossId.mohg,
        emblemAsset: AppAssets.mohg,
        aliveAsset: AppAssets.mohg,
        deadAsset: AppAssets.mohgDead,
        glowPalette: BossGlowPalette.mohg,
      ),
      CpuBossId.malenia => const BossPresentation(
        id: CpuBossId.malenia,
        emblemAsset: AppAssets.malenia,
        aliveAsset: AppAssets.malenia,
        deadAsset: AppAssets.maleniaDead,
        glowPalette: BossGlowPalette.malenia,
      ),
    };
  }
}
