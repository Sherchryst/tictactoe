import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/di/game_dependencies.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_timing.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_view_state.dart';
import 'package:tictactoe/features/game/presentation/controllers/no_mercy_run_persistence.dart';
import 'package:tictactoe/features/game/presentation/controllers/no_mercy_run_status.dart';
import 'package:tictactoe/features/game/presentation/controllers/scoreboard_controller.dart';
import 'package:tictactoe/features/game/presentation/utils/audio/game_music_cue_resolver.dart';

part 'game_controller.g.dart';

@Riverpod(keepAlive: true)
GameTiming gameTiming(Ref ref) => const GameTiming();

@Riverpod(keepAlive: true)
final class GameController extends _$GameController {
  static const _musicCues = GameMusicCueResolver();

  var _turnVersion = 0;

  @override
  GameViewState build() => GameViewState.initial();

  Future<void> startLocalDuel() async {
    await _startSession(GameSetup.localDuel());
  }

  Future<void> startGuidedTrial() async {
    await _startSession(GameSetup.guidedTrial());
  }

  Future<void> startNoMercyRun() async {
    await _startFreshNoMercyRun(clearExistingProgress: false);
  }

  Future<void> restartNoMercyRun() async {
    await _startFreshNoMercyRun(clearExistingProgress: true);
  }

  Future<bool> continueNoMercyRun() async {
    _turnVersion++;
    final session = await ref.read(loadNoMercyRunProvider).call();
    if (session == null) {
      _invalidateNoMercyRunStatus();
      return false;
    }

    final phase = _restoredPhaseFor(session);
    state = GameViewState(
      session: session,
      phase: phase,
      hasPreparedSession: true,
    );
    unawaited(_playTrackFor(session));

    if (phase == GameViewPhase.cpuThinking) {
      unawaited(_runCpuTurn(_turnVersion));
    }

    return true;
  }

  Future<void> startGame(GameSetup setup) async {
    return switch (setup.mode) {
      GameMode.localDuel => startLocalDuel(),
      GameMode.guidedTrial => startGuidedTrial(),
      GameMode.noMercyRun => restartNoMercyRun(),
    };
  }

  Future<void> startNewRound() async {
    _turnVersion++;
    final previous = state.session;
    final session = ref
        .read(startNewRoundProvider)
        .call(previous, bossId: previous.bossId);

    state = GameViewState(session: session, hasPreparedSession: true);
    if (session.isNoMercy) {
      await _saveNoMercyRun(session);
      unawaited(_playTrackFor(session));
    }
  }

  Future<bool> advanceNoMercyRun() async {
    final previous = state.session;
    final nextProgression = ref
        .read(noMercyRunProgressionProvider)
        .nextAfterRound(previous);
    if (nextProgression == null) {
      return false;
    }

    _turnVersion++;
    final session = ref
        .read(startNewRoundProvider)
        .call(
          previous,
          bossId: nextProgression.bossId,
          noMercyCycle: nextProgression.noMercyCycle,
        );

    state = GameViewState(session: session, hasPreparedSession: true);
    await _saveNoMercyRun(session);
    unawaited(_playTrackFor(session));
    return true;
  }

  Future<void> _startSession(GameSetup setup) async {
    _turnVersion++;
    final session = ref.read(startGameProvider).call(setup);
    state = GameViewState(session: session, hasPreparedSession: true);
    unawaited(_playTrackFor(session));
  }

  Future<void> _startFreshNoMercyRun({
    required bool clearExistingProgress,
  }) async {
    _turnVersion++;
    if (clearExistingProgress) {
      await ref.read(noMercyRunPersistenceProvider).clear();
      _invalidateNoMercyRunStatus();
    }

    final session = ref
        .read(startGameProvider)
        .call(GameSetup.noMercy(CpuBossId.radahn));
    state = GameViewState(session: session, hasPreparedSession: true);
    await _saveNoMercyRun(session);
    unawaited(_playTrackFor(session));
  }

  Future<void> playCell(int cellIndex) {
    return _playCell(cellIndex);
  }

  Future<void> _playCell(int cellIndex) async {
    if (state.phase != GameViewPhase.awaitingHumanMove) {
      return;
    }

    final previous = state;
    final afterHuman = ref
        .read(playHumanMoveProvider)
        .call(previous.session, cellIndex);
    if (afterHuman == previous.session) {
      return;
    }

    final turnVersion = ++_turnVersion;
    state = previous.copyWith(
      session: afterHuman,
      phase: GameViewPhase.humanMoveAnimating,
    );
    await _saveNoMercyRun(afterHuman);
    final timing = ref.read(gameTimingProvider);
    await _guardedDelay(timing.markReveal, turnVersion);

    if (!_isCurrentTurn(turnVersion)) {
      return;
    }

    if (afterHuman.result.isOngoing && afterHuman.hasCpuOpponent) {
      state = state.copyWith(phase: GameViewPhase.cpuThinking);
      await _runCpuTurn(turnVersion);
      return;
    }

    await _settleAfterMove(turnVersion);
  }

  Future<void> _runCpuTurn(int turnVersion) async {
    final timing = ref.read(gameTimingProvider);
    await _guardedDelay(timing.cpuThinking, turnVersion);
    if (!_isCurrentTurn(turnVersion)) {
      return;
    }

    final beforeCpu = state.session;
    final afterCpu = ref.read(playCpuTurnProvider).call(beforeCpu);
    if (afterCpu == beforeCpu) {
      state = state.copyWith(phase: GameViewPhase.awaitingHumanMove);
      return;
    }

    state = state.copyWith(
      session: afterCpu,
      phase: GameViewPhase.cpuMoveAnimating,
    );
    await _saveNoMercyRun(afterCpu);
    await _guardedDelay(timing.markReveal, turnVersion);
    await _settleAfterMove(turnVersion);
  }

  Future<void> _settleAfterMove(int turnVersion) async {
    if (!_isCurrentTurn(turnVersion)) {
      return;
    }

    final session = state.session;
    if (session.result.isOngoing) {
      state = state.copyWith(phase: GameViewPhase.awaitingHumanMove);
      await _saveNoMercyRun(session);
      return;
    }

    await _recordOutcomeIfNeeded(session);
    state = state.copyWith(phase: GameViewPhase.outcomeRevealing);
    await _saveNoMercyRun(session);
    await _guardedDelay(ref.read(gameTimingProvider).roundOver, turnVersion);
    if (_isCurrentTurn(turnVersion) &&
        state.phase == GameViewPhase.outcomeRevealing) {
      state = state.copyWith(phase: GameViewPhase.roundOver);
    }
  }

  Future<void> _recordOutcomeIfNeeded(GameSession session) async {
    if (state.hasRecordedOutcome) {
      return;
    }

    final scoreboard = await ref
        .read(scoreboardControllerProvider.notifier)
        .recordNoMercyOutcome(session);
    if (scoreboard == null) {
      return;
    }

    state = state.copyWith(hasRecordedOutcome: true);

    if (session.completedMaxNoMercyCycle) {
      await ref.read(noMercyRunPersistenceProvider).clear();
      _invalidateNoMercyRunStatus();
    }
  }

  Future<void> _saveNoMercyRun(GameSession session) async {
    final saved = await ref
        .read(noMercyRunPersistenceProvider)
        .saveForContinue(session);
    if (!saved) {
      return;
    }

    _invalidateNoMercyRunStatus();
  }

  Future<void> _playTrackFor(GameSession session) {
    return ref
        .read(audioControllerProvider)
        .playTrack(_musicCues.trackFor(session));
  }

  void _invalidateNoMercyRunStatus() {
    ref.invalidate(noMercyRunStatusProvider);
    ref.invalidate(noMercyRunExistsProvider);
    ref.invalidate(noMercyCreditsUnlockedProvider);
  }

  Future<void> _guardedDelay(Duration duration, int turnVersion) async {
    await ref.read(gameTimingProvider).wait(duration);
    if (!_isCurrentTurn(turnVersion)) {
      return;
    }
  }

  bool _isCurrentTurn(int turnVersion) => turnVersion == _turnVersion;

  GameViewPhase _restoredPhaseFor(GameSession session) {
    if (!session.result.isOngoing) {
      return GameViewPhase.roundOver;
    }

    return session.canHumanPlay
        ? GameViewPhase.awaitingHumanMove
        : GameViewPhase.cpuThinking;
  }
}
