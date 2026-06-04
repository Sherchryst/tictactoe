enum CpuBossId {
  guided,
  radahn,
  mohg,
  malenia;

  bool get isNoMercy {
    return switch (this) {
      CpuBossId.guided => false,
      CpuBossId.radahn || CpuBossId.mohg || CpuBossId.malenia => true,
    };
  }

  CpuBossId? get nextNoMercyBoss {
    return switch (this) {
      CpuBossId.guided => CpuBossId.radahn,
      CpuBossId.radahn => CpuBossId.mohg,
      CpuBossId.mohg => CpuBossId.malenia,
      CpuBossId.malenia => null,
    };
  }
}
