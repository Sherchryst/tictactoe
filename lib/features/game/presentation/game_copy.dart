import 'package:flutter/widgets.dart';

import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/presentation/copy/game_status_resolver.dart';
import 'package:tictactoe/features/game/presentation/copy/player_label_resolver.dart';
import 'package:tictactoe/features/game/presentation/copy/system_help_resolver.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

final class GameCopy {
  GameCopy._(this._l10n)
    : _playerLabels = PlayerLabelResolver(_l10n),
      _statuses = GameStatusResolver(_l10n),
      _systemHelp = SystemHelpResolver(_l10n);

  static const appTitle = 'Tic Tac Toe';

  final AppLocalizations _l10n;
  final PlayerLabelResolver _playerLabels;
  final GameStatusResolver _statuses;
  final SystemHelpResolver _systemHelp;

  static GameCopy of(BuildContext context) {
    return GameCopy._(AppLocalizations.of(context));
  }

  String get touchScreenPrompt => _l10n.touchScreenPrompt;
  String get gameTitle => _l10n.gameTitle;
  String get loadingTitle => _l10n.loadingTitle;
  String get loadingFooter => _l10n.loadingFooter;
  String get settingsTitle => _l10n.settingsTitle;
  String get systemHeaderTitle => _l10n.systemHeaderTitle;
  String get homeTooltip => _l10n.homeTooltip;
  String get backTooltip => _l10n.backTooltip;
  String get localGameAction => _l10n.localGameAction;
  String get aiGameAction => _l10n.aiGameAction;
  String get resetScoreAction => _l10n.resetScoreAction;
  String get selectDifficultyTitle => _l10n.selectDifficultyTitle;
  String get selectDifficultyMessage => _l10n.selectDifficultyMessage;
  String get gameOverTitle => _l10n.gameOverTitle;
  String get playAgainAction => _l10n.playAgainAction;
  String get goHomeAction => _l10n.goHomeAction;
  String get vsLabel => _l10n.vsLabel;
  String get audioTitle => _l10n.audioTitle;
  String get languageTitle => _l10n.languageTitle;
  String get musicTitle => _l10n.musicTitle;
  String get sfxTitle => _l10n.sfxTitle;
  String get musicVolumeLabel => _l10n.musicVolumeLabel;
  String get sfxVolumeLabel => _l10n.sfxVolumeLabel;
  String get scoreTitle => _l10n.scoreTitle;
  String get easyLabel => _l10n.easyLabel;
  String get hardLabel => _l10n.hardLabel;
  String get humanScoreLabel => _l10n.humanScoreLabel;
  String get cpuScoreLabel => _l10n.cpuScoreLabel;
  String get drawsScoreLabel => _l10n.drawsScoreLabel;
  String get duelsFoughtLabel => _l10n.duelsFoughtLabel;
  String get resetScoreHint => _l10n.resetScoreHint;
  String get drawStatus => _l10n.drawStatus;
  String get drawDialogTitle => _l10n.drawDialogTitle;
  String get settingsLoadError => _l10n.settingsLoadError;
  String get onLabel => _l10n.onLabel;
  String get offLabel => _l10n.offLabel;
  String get soundOptionsTitle => _l10n.soundOptionsTitle;
  String get recordTitle => _l10n.recordTitle;
  String get languageOptionsTitle => _l10n.languageOptionsTitle;

  String gameModeTitle(GameMode mode) {
    return switch (mode) {
      GameMode.humanVsCpu => _l10n.humanVsCpuLabel,
      GameMode.humanVsHuman => _l10n.humanVsHumanLabel,
    };
  }

  String languageLabel(AppLocalePreference localePreference) {
    return switch (localePreference) {
      AppLocalePreference.english => _l10n.englishLanguageLabel,
      AppLocalePreference.french => _l10n.frenchLanguageLabel,
      AppLocalePreference.spanish => _l10n.spanishLanguageLabel,
      AppLocalePreference.german => _l10n.germanLanguageLabel,
    };
  }

  String winDialogTitle(Player winner, GameMode mode) {
    return _playerLabels.win(winner, mode);
  }

  String scoreLabelFor(Player player, GameMode mode) {
    return _playerLabels.score(player, mode);
  }

  String statusFor(
    GameResult result,
    Player currentPlayer, {
    GameMode mode = GameMode.humanVsCpu,
  }) {
    return _statuses.resolve(result, currentPlayer, mode);
  }

  String helpTextForAudio(int focusedRowIndex) {
    return _systemHelp.forAudio(focusedRowIndex);
  }

  String helpTextForScore(int focusedRowIndex) {
    return _systemHelp.forScore(focusedRowIndex);
  }

  String helpTextForLanguage(int focusedRowIndex) {
    return _systemHelp.forLanguage(focusedRowIndex);
  }
}
