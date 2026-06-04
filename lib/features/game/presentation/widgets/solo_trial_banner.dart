import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/core/design_system/widgets/app_haptics.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/presentation/utils/styles/solo_trial_banner_style.dart';
import 'package:tictactoe/features/game/presentation/utils/text/player_label_resolver.dart';
import 'package:tictactoe/features/game/presentation/widgets/solo_trial_banner_frame.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class SoloTrialBanner extends HookWidget {
  const SoloTrialBanner({required this.session, super.key});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final banner = _bannerFor(
      session,
      PlayerLabelResolver(AppLocalizations.of(context)),
    );
    final activeLabel = banner?.label;

    useEffect(() {
      if (activeLabel != null) {
        AppHaptics.outcome();
      }
      return null;
    }, [activeLabel]);

    if (banner == null) {
      return const SizedBox.shrink();
    }

    final screen = MediaQuery.sizeOf(context);
    final bandHeight = (screen.height * 0.105).clamp(78.0, 118.0).toDouble();

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            key: ValueKey(banner.label),
            tween: Tween(begin: 0, end: 1),
            duration: banner.totalAnimationDuration,
            builder: (context, value, child) {
              final elapsed = Duration(
                milliseconds:
                    (banner.totalAnimationDuration.inMilliseconds * value)
                        .round(),
              );
              final bandProgress = AppCurves.entrance.transform(
                (elapsed.inMilliseconds /
                        banner.bandGrowDuration.inMilliseconds)
                    .clamp(0.0, 1.0),
              );
              final textProgress = AppCurves.entrance.transform(
                ((elapsed - banner.textRevealDelay).inMilliseconds /
                        banner.textFadeDuration.inMilliseconds)
                    .clamp(0.0, 1.0),
              );

              return SoloTrialBannerFrame(
                banner: banner,
                bandHeight: bandHeight,
                lineProgress: bandProgress,
                revealProgress: textProgress,
              );
            },
          ),
        ),
      ),
    );
  }

  SoloTrialBannerStyle? _bannerFor(
    GameSession session,
    PlayerLabelResolver labels,
  ) {
    if (session.mode == GameMode.localDuel) {
      return null;
    }

    return switch (session.result) {
      GameWin() when session.participantOutcome == GameOutcome.humanWin =>
        SoloTrialBannerStyle.humanWin(
          label: labels.result(session),
          guided: session.mode == GameMode.guidedTrial,
        ),
      GameWin() => SoloTrialBannerStyle.cpuWin(label: labels.result(session)),
      GameDraw() || GameOngoing() => null,
    };
  }
}
