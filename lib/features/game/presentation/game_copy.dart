import '../domain/entities/cell.dart';
import '../domain/entities/game_difficulty.dart';
import '../domain/entities/game_mode.dart';
import '../domain/entities/game_result.dart';
import '../domain/entities/player.dart';

final class GameCopy {
  const GameCopy._();

  static const appTitle = 'Tic Tac Toe';
  static const homeTitle = appTitle;
  static const gameTitle = 'Game';
  static const settingsTitle = 'Preferences';
  static const gameSettingsTitle = settingsTitle;

  static const settingsTooltip = settingsTitle;
  static const homeTooltip = 'Home';
  static const backTooltip = 'Back';

  static const humanVsCpuLabel = 'vs AI';
  static const humanVsHumanLabel = '1 vs 1';
  static const localGameAction = '1 vs 1';
  static const aiGameAction = 'vs AI';
  static const playAction = 'Start game';
  static const newRoundAction = 'Play again';
  static const resetScoreAction = 'Reset score';
  static const selectDifficultyTitle = 'Solo';
  static const selectDifficultyMessage = 'Select difficulty';
  static const gameOverTitle = 'Game over';
  static const playAgainAction = 'Play again';
  static const goHomeAction = 'Go home';
  static const vsLabel = 'vs';

  static const modeTitle = 'Mode';
  static const difficultyTitle = 'Difficulty';
  static const themeTitle = 'Theme';
  static const scoreTitle = 'Score';

  static const easyLabel = 'Easy';
  static const mediumLabel = 'Medium';
  static const hardLabel = 'Hard';
  static const systemThemeLabel = 'System';
  static const lightThemeLabel = 'Light';
  static const darkThemeLabel = 'Dark';

  static const humanScoreLabel = 'You';
  static const cpuScoreLabel = 'CPU';
  static const playerXScoreLabel = 'Player X';
  static const playerOScoreLabel = 'Player O';
  static const drawsScoreLabel = 'Draws';

  static const humanMark = 'X';
  static const cpuMark = 'O';
  static const emptyMark = '';

  static const humanTurnStatus = 'Your turn';
  static const cpuTurnStatus = 'CPU turn';
  static const playerXTurnStatus = 'Player X turn';
  static const playerOTurnStatus = 'Player O turn';
  static const humanWinStatus = 'You win';
  static const cpuWinStatus = 'CPU wins';
  static const playerXWinStatus = 'Player X wins';
  static const playerOWinStatus = 'Player O wins';
  static const drawStatus = 'Draw';
  static const drawDialogTitle = 'It is a draw';

  static const scoreUnavailable = 'Score unavailable';
  static const settingsLoadError = 'Unable to load settings.';
  static const gameSettingsLoadError = 'Unable to load game settings.';

  static String gameModeTitle(GameMode mode) {
    return switch (mode) {
      GameMode.humanVsCpu => humanVsCpuLabel,
      GameMode.humanVsHuman => humanVsHumanLabel,
    };
  }

  static String winDialogTitle(Player winner, GameMode mode) {
    return switch (mode) {
      GameMode.humanVsCpu =>
        winner == Player.human ? humanWinStatus : cpuWinStatus,
      GameMode.humanVsHuman =>
        winner == Player.human ? playerXWinStatus : playerOWinStatus,
    };
  }

  static String scoreLabelFor(Player player, GameMode mode) {
    return switch (mode) {
      GameMode.humanVsCpu =>
        player == Player.human ? humanScoreLabel : cpuScoreLabel,
      GameMode.humanVsHuman =>
        player == Player.human ? playerXScoreLabel : playerOScoreLabel,
    };
  }

  static String statusFor(
    GameResult result,
    Player currentPlayer, {
    GameMode mode = GameMode.humanVsCpu,
  }) {
    return switch (result) {
      GameOngoing() => _turnStatusFor(currentPlayer, mode),
      GameWin(:final winner) => _winStatusFor(winner, mode),
      GameDraw() => drawStatus,
    };
  }

  static String markFor(Cell cell) {
    return switch (cell) {
      Cell.human => humanMark,
      Cell.cpu => cpuMark,
      Cell.empty => emptyMark,
    };
  }

  static String _turnStatusFor(Player player, GameMode mode) {
    return switch (mode) {
      GameMode.humanVsCpu =>
        player == Player.human ? humanTurnStatus : cpuTurnStatus,
      GameMode.humanVsHuman =>
        player == Player.human ? playerXTurnStatus : playerOTurnStatus,
    };
  }

  static String _winStatusFor(Player player, GameMode mode) {
    return switch (mode) {
      GameMode.humanVsCpu =>
        player == Player.human ? humanWinStatus : cpuWinStatus,
      GameMode.humanVsHuman =>
        player == Player.human ? playerXWinStatus : playerOWinStatus,
    };
  }
}

extension GameModeCopy on GameMode {
  String get label {
    return switch (this) {
      GameMode.humanVsCpu => GameCopy.humanVsCpuLabel,
      GameMode.humanVsHuman => GameCopy.humanVsHumanLabel,
    };
  }
}

extension GameDifficultyCopy on GameDifficulty {
  String get label {
    return switch (this) {
      GameDifficulty.easy => GameCopy.easyLabel,
      GameDifficulty.medium => GameCopy.mediumLabel,
      GameDifficulty.hard => GameCopy.hardLabel,
    };
  }
}
