import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/di/game_dependencies.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/game_difficulty.dart';
import 'package:tictactoe/features/game/domain/entities/game_mode.dart';
import 'package:tictactoe/features/game/domain/entities/game_settings.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/usecases/play_human_move.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/settings/presentation/controllers/settings_controller.dart';

import '../../../../helpers/fake_key_value_storage.dart';

void main() {
  ProviderContainer createContainer({
    required FakeKeyValueStorage storage,
    CpuStrategy? easyStrategy,
  }) {
    final container = ProviderContainer(
      overrides: [
        keyValueStorageProvider.overrideWithValue(storage),
        if (easyStrategy != null)
          playHumanMoveProvider.overrideWithValue(
            PlayHumanMove(easyStrategy: easyStrategy),
          ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('starts a game with a settings snapshot', () {
    final container = createContainer(storage: FakeKeyValueStorage());
    const settings = GameSettings(
      mode: GameMode.humanVsHuman,
      difficulty: GameDifficulty.hard,
    );

    container.read(gameControllerProvider.notifier).startGame(settings);

    final state = container.read(gameControllerProvider);
    expect(state.session.mode, GameMode.humanVsHuman);
    expect(state.session.difficulty, GameDifficulty.hard);
  });

  test('plays a human turn and records a finished game once', () async {
    final storage = FakeKeyValueStorage();
    final container = createContainer(
      storage: storage,
      easyStrategy: QueueCpuStrategy([8, 7]),
    );
    await container.read(settingsControllerProvider.future);

    container
        .read(gameControllerProvider.notifier)
        .startGame(const GameSettings(difficulty: GameDifficulty.easy));
    container.read(gameControllerProvider.notifier).playCell(0);
    container.read(gameControllerProvider.notifier).playCell(1);
    container.read(gameControllerProvider.notifier).playCell(2);
    await Future<void>.delayed(Duration.zero);
    await container.pump();

    final game = container.read(gameControllerProvider);
    final settings = container.read(settingsControllerProvider).requireValue;

    expect(game.session.board.cellAt(0), Cell.human);
    expect(game.session.board.cellAt(8), Cell.cpu);
    expect(game.hasRecordedOutcome, isTrue);
    expect(settings.scoreboard.humanWins, 1);
  });
}

final class QueueCpuStrategy implements CpuStrategy {
  QueueCpuStrategy(List<int> moves) : _moves = List.of(moves);

  final List<int> _moves;

  @override
  int chooseMove(Board board, Player player) {
    return _moves.removeAt(0);
  }
}
