import 'package:tictactoe/features/game/domain/entities/boss_pattern.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_rules.dart';

final class BossPatterns {
  const BossPatterns._();

  static const radahn = BossPattern(
    bossId: CpuBossId.radahn,
    noMercyCycle: 0,
    humanMoves: [1, 8, 3, 0, 6],
    cpuMoves: [2, 5, 7, 4],
  );

  static const mohg = BossPattern(
    bossId: CpuBossId.mohg,
    noMercyCycle: 0,
    humanMoves: [2, 7, 5, 4, 6],
    cpuMoves: [8, 1, 0, 3],
  );

  static const malenia = BossPattern(
    bossId: CpuBossId.malenia,
    noMercyCycle: 0,
    humanMoves: [7, 5, 0, 8, 4],
    cpuMoves: [3, 1, 2, 6],
  );

  static const radahnNgPlus1 = BossPattern(
    bossId: CpuBossId.radahn,
    noMercyCycle: 1,
    humanMoves: [3, 1, 6, 4, 5],
    cpuMoves: [0, 8, 7, 2],
  );

  static const mohgNgPlus1 = BossPattern(
    bossId: CpuBossId.mohg,
    noMercyCycle: 1,
    humanMoves: [6, 1, 8, 2, 5],
    cpuMoves: [7, 3, 4, 0],
  );

  static const maleniaNgPlus1 = BossPattern(
    bossId: CpuBossId.malenia,
    noMercyCycle: 1,
    humanMoves: [0, 7, 2, 8, 4],
    cpuMoves: [6, 3, 1, 5],
  );

  static const radahnNgPlus2 = BossPattern(
    bossId: CpuBossId.radahn,
    noMercyCycle: 2,
    humanMoves: [5, 1, 6, 4, 2],
    cpuMoves: [0, 7, 8, 3],
  );

  static const mohgNgPlus2 = BossPattern(
    bossId: CpuBossId.mohg,
    noMercyCycle: 2,
    humanMoves: [8, 1, 3, 4, 5],
    cpuMoves: [0, 2, 6, 7],
  );

  static const maleniaNgPlus2 = BossPattern(
    bossId: CpuBossId.malenia,
    noMercyCycle: 2,
    humanMoves: [2, 3, 7, 0, 1],
    cpuMoves: [5, 8, 4, 6],
  );

  static const radahnNgPlus3 = BossPattern(
    bossId: CpuBossId.radahn,
    noMercyCycle: 3,
    humanMoves: [7, 3, 2, 6, 0],
    cpuMoves: [1, 5, 4, 8],
  );

  static const mohgNgPlus3 = BossPattern(
    bossId: CpuBossId.mohg,
    noMercyCycle: 3,
    humanMoves: [0, 7, 5, 8, 4],
    cpuMoves: [2, 1, 3, 6],
  );

  static const maleniaNgPlus3 = BossPattern(
    bossId: CpuBossId.malenia,
    noMercyCycle: 3,
    humanMoves: [8, 3, 1, 4, 7],
    cpuMoves: [2, 6, 5, 0],
  );

  static const radahnNgPlus4 = BossPattern(
    bossId: CpuBossId.radahn,
    noMercyCycle: 4,
    humanMoves: [6, 1, 5, 2, 0],
    cpuMoves: [7, 8, 3, 4],
  );

  static const mohgNgPlus4 = BossPattern(
    bossId: CpuBossId.mohg,
    noMercyCycle: 4,
    humanMoves: [3, 7, 2, 5, 4],
    cpuMoves: [0, 6, 1, 8],
  );

  static const maleniaNgPlus4 = BossPattern(
    bossId: CpuBossId.malenia,
    noMercyCycle: 4,
    humanMoves: [5, 0, 7, 8, 6],
    cpuMoves: [2, 3, 1, 4],
  );

  static const all = [
    radahn,
    mohg,
    malenia,
    radahnNgPlus1,
    mohgNgPlus1,
    maleniaNgPlus1,
    radahnNgPlus2,
    mohgNgPlus2,
    maleniaNgPlus2,
    radahnNgPlus3,
    mohgNgPlus3,
    maleniaNgPlus3,
    radahnNgPlus4,
    mohgNgPlus4,
    maleniaNgPlus4,
  ];

  static BossPattern? forBoss(CpuBossId bossId, {int noMercyCycle = 0}) {
    final cycle = noMercyCycle.clamp(0, maxNoMercyCycle).toInt();
    return switch (bossId) {
      CpuBossId.guided => null,
      CpuBossId.radahn => _radahnByCycle[cycle],
      CpuBossId.mohg => _mohgByCycle[cycle],
      CpuBossId.malenia => _maleniaByCycle[cycle],
    };
  }

  static const _radahnByCycle = [
    radahn,
    radahnNgPlus1,
    radahnNgPlus2,
    radahnNgPlus3,
    radahnNgPlus4,
  ];

  static const _mohgByCycle = [
    mohg,
    mohgNgPlus1,
    mohgNgPlus2,
    mohgNgPlus3,
    mohgNgPlus4,
  ];

  static const _maleniaByCycle = [
    malenia,
    maleniaNgPlus1,
    maleniaNgPlus2,
    maleniaNgPlus3,
    maleniaNgPlus4,
  ];
}
