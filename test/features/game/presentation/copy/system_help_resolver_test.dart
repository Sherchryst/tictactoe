import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/presentation/copy/system_help_resolver.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final resolver = SystemHelpResolver(l10n);

  group('SystemHelpResolver', () {
    test('maps audio rows to their dedicated copy', () {
      expect(resolver.forAudio(0), l10n.audioMusicToggleHelp);
      expect(resolver.forAudio(1), l10n.audioMusicVolumeHelp);
      expect(resolver.forAudio(2), l10n.audioSfxToggleHelp);
      expect(resolver.forAudio(3), l10n.audioSfxVolumeHelp);
      expect(resolver.forAudio(99), l10n.audioDefaultHelp);
    });

    test('maps score record rows to the same explanation', () {
      expect(resolver.forScore(0), l10n.scoreRecordHelp);
      expect(resolver.forScore(3), l10n.scoreRecordHelp);
      expect(resolver.forScore(4), l10n.scoreResetHelp);
      expect(resolver.forScore(99), l10n.scoreDefaultHelp);
    });

    test('maps language rows to their copy', () {
      expect(resolver.forLanguage(0), l10n.languageEnglishHelp);
      expect(resolver.forLanguage(1), l10n.languageFrenchHelp);
      expect(resolver.forLanguage(2), l10n.languageSpanishHelp);
      expect(resolver.forLanguage(3), l10n.languageGermanHelp);
      expect(resolver.forLanguage(99), l10n.languageDefaultHelp);
    });
  });
}
