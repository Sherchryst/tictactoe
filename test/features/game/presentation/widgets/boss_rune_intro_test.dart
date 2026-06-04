import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/presentation/audio/game_audio_effects.dart';
import 'package:tictactoe/features/game/presentation/widgets/boss_rune_intro.dart';

void main() {
  Future<int> pumpIntro(
    WidgetTester tester,
    GameSession session, {
    Object animationKey = 'round',
  }) async {
    var sounds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 430,
          height: 780,
          child: Stack(
            children: [
              BossRuneIntro(
                session: session,
                animationKey: animationKey,
                onSeal: () => sounds++,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(GameAudioEffects.bossRuneIntroSoundDelay);
    await tester.pump();
    return sounds;
  }

  testWidgets('plays the intro callback once for a boss round', (tester) async {
    final sounds = await pumpIntro(
      tester,
      GameSession.newGame(GameSetup.noMercy(CpuBossId.radahn)),
    );

    expect(sounds, 1);
  });

  testWidgets('keeps the boss rune visible for two seconds before returning', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 430,
          height: 780,
          child: Stack(
            children: [
              BossRuneIntro(
                session: GameSession.newGame(GameSetup.noMercy(CpuBossId.mohg)),
                animationKey: 'mohg',
                onSeal: () {},
                onComplete: () {
                  completed = true;
                },
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 2));

    expect(find.image(const AssetImage(AppAssets.mohg)), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.image(const AssetImage(AppAssets.mohg)), findsNothing);
    expect(completed, isTrue);
  });

  testWidgets('does not play the intro for local duels', (tester) async {
    final sounds = await pumpIntro(
      tester,
      GameSession.newGame(GameSetup.localDuel()),
    );

    expect(sounds, 0);
  });
}
