import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/presentation/utils/text/score_help_resolver.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final resolver = ScoreHelpResolver(l10n);

  group('ScoreHelpResolver', () {
    test('maps score record rows to the same explanation', () {
      expect(resolver.resolve(0), l10n.scoreRecordHelp);
      expect(resolver.resolve(3), l10n.scoreRecordHelp);
      expect(resolver.resolve(4), l10n.scoreResetHelp);
      expect(resolver.resolve(99), l10n.scoreDefaultHelp);
    });
  });
}
