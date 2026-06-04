import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictactoe/core/di/game_dependencies.dart';
import 'package:tictactoe/features/game/presentation/controllers/scoreboard_controller.dart';

part 'no_mercy_run_status.g.dart';

final class NoMercyRunStatus {
  const NoMercyRunStatus({
    required this.hasSavedRun,
    required this.creditsUnlocked,
  });

  static const none = NoMercyRunStatus(
    hasSavedRun: false,
    creditsUnlocked: false,
  );

  final bool hasSavedRun;
  final bool creditsUnlocked;
}

@Riverpod(keepAlive: true)
Future<NoMercyRunStatus> noMercyRunStatus(Ref ref) async {
  final session = await ref.watch(loadNoMercyRunProvider).call();
  final creditsUnlockedFromProgress =
      session != null && session.noMercyCycle > 0;

  if (creditsUnlockedFromProgress) {
    return const NoMercyRunStatus(hasSavedRun: true, creditsUnlocked: true);
  }

  final scoreboard = await ref.watch(scoreboardControllerProvider.future);
  return NoMercyRunStatus(
    hasSavedRun: session != null,
    creditsUnlocked: scoreboard.malenia.humanWins > 0,
  );
}

@Riverpod(keepAlive: true)
Future<bool> noMercyRunExists(Ref ref) async {
  final status = await ref.watch(noMercyRunStatusProvider.future);
  return status.hasSavedRun;
}

@Riverpod(keepAlive: true)
Future<bool> noMercyCreditsUnlocked(Ref ref) async {
  final status = await ref.watch(noMercyRunStatusProvider.future);
  return status.creditsUnlocked;
}
