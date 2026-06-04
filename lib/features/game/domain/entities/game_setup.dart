import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_rules.dart';

part 'game_setup.freezed.dart';

enum GameMode { localDuel, guidedTrial, noMercyRun }

@freezed
abstract class GameSetup with _$GameSetup {
  const GameSetup._();

  const factory GameSetup({
    @Default(GameMode.guidedTrial) GameMode mode,
    @Default(CpuBossId.guided) CpuBossId bossId,
    @Default(0) int noMercyCycle,
  }) = _GameSetup;

  factory GameSetup.defaults() => const GameSetup();

  factory GameSetup.localDuel() {
    return const GameSetup(mode: GameMode.localDuel);
  }

  factory GameSetup.guidedTrial() {
    return const GameSetup();
  }

  factory GameSetup.noMercy(CpuBossId bossId, {int noMercyCycle = 0}) {
    return GameSetup(
      mode: GameMode.noMercyRun,
      bossId: bossId,
      noMercyCycle: noMercyCycle.clamp(0, maxNoMercyCycle).toInt(),
    );
  }
}
