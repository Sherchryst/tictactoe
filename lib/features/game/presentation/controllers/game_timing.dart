import 'package:tictactoe/core/design_system/tokens/app_durations.dart';

final class GameTiming {
  const GameTiming({
    this.cpuThinking = const Duration(milliseconds: 520),
    this.markReveal = AppDurations.boardMarkReveal,
    this.roundOver = const Duration(milliseconds: 320),
  });

  const GameTiming.immediate()
    : cpuThinking = Duration.zero,
      markReveal = Duration.zero,
      roundOver = Duration.zero;

  final Duration cpuThinking;
  final Duration markReveal;
  final Duration roundOver;

  Future<void> wait(Duration duration) {
    if (duration == Duration.zero) {
      return Future<void>.value();
    }

    return Future<void>.delayed(duration);
  }
}
