import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_setup.freezed.dart';

enum GameMode { humanVsCpu, humanVsHuman }

enum GameDifficulty { easy, hard }

@freezed
abstract class GameSetup with _$GameSetup {
  const GameSetup._();

  const factory GameSetup({
    @Default(GameMode.humanVsCpu) GameMode mode,
    @Default(GameDifficulty.hard) GameDifficulty difficulty,
  }) = _GameSetup;

  factory GameSetup.defaults() => const GameSetup();
}
