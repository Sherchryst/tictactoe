import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tictactoe/app/di/audio_providers.dart';
import 'package:tictactoe/app/router/app_routes.dart';
import 'package:tictactoe/app/router/hero_tags.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/design_system/tokens/app_animations.dart';
import 'package:tictactoe/design_system/tokens/app_durations.dart';
import 'package:tictactoe/design_system/tokens/app_gradients.dart';
import 'package:tictactoe/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/design_system/widgets/ambient_motes.dart';
import 'package:tictactoe/design_system/widgets/fog_veil.dart';
import 'package:tictactoe/design_system/widgets/gilded_text.dart';
import 'package:tictactoe/design_system/widgets/grace_glow.dart';
import 'package:tictactoe/design_system/widgets/rune_diamond.dart';
import 'package:tictactoe/design_system/widgets/sigil_backdrop.dart';
import 'package:tictactoe/design_system/widgets/tic_tac_toe_title_logo.dart';
import 'package:tictactoe/features/game/domain/entities/music_track.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';
import 'package:tictactoe/features/game/presentation/widgets/loading/loading_beam.dart';

class GameLoadingPage extends HookConsumerWidget {
  const GameLoadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: AppDurations.loadingScreen,
    );

    useEffect(() {
      unawaited(_runLoadingTransition(context, ref, controller));

      return null;
    }, const []);

    final screen = MediaQuery.sizeOf(context);
    final copy = GameCopy.of(context);
    final logoFontSize = (screen.shortestSide * 0.13)
        .clamp(46.0, 60.0)
        .toDouble();
    final sigilSize = (screen.shortestSide * 1.08)
        .clamp(380.0, 560.0)
        .toDouble();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: AppPalette.backgroundDeep),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GraceGlow(
              animation: controller,
              alignment: const Alignment(0, -0.04),
              radius: 0.82,
              intensity: 0.85,
            ),
            _LoadingSigil(animation: controller, size: sigilSize),
            FogVeil(animation: controller, intensity: 0.9),
            AmbientMotes(
              controller: controller,
              count: 44,
              maxAlpha: AppAlphas.muted,
            ),
            DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.sideVignette()),
            ),
            DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.topShade()),
            ),
            _LoadingForeground(
              animation: controller,
              screen: screen,
              logoFontSize: logoFontSize,
              title: copy.loadingTitle,
              footer: copy.loadingFooter,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runLoadingTransition(
    BuildContext context,
    WidgetRef ref,
    AnimationController controller,
  ) async {
    final audio = ref.read(audioControllerProvider);
    unawaited(
      audio.prepareGame().then((_) => audio.playTrack(MusicTrack.game)),
    );

    try {
      await controller.forward().orCancel;
    } on TickerCanceled {
      return;
    }

    if (!context.mounted) {
      return;
    }

    context.go(AppRoutes.gameLocation);
  }
}

class _LoadingForeground extends StatelessWidget {
  const _LoadingForeground({
    required this.animation,
    required this.screen,
    required this.logoFontSize,
    required this.title,
    required this.footer,
  });

  final Animation<double> animation;
  final Size screen;
  final double logoFontSize;
  final String title;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final logoDrop = AppAnimations.interval(
          progress,
          begin: 0,
          end: 0.78,
          curve: Curves.easeInOutCubic,
        );
        final contentIn = AppAnimations.interval(
          progress,
          begin: 0.18,
          end: 0.58,
          curve: Curves.easeOutCubic,
        );
        final footerIn = AppAnimations.interval(
          progress,
          begin: 0.42,
          end: 0.82,
          curve: Curves.easeOutCubic,
        );
        final logoTop =
            screen.height * 0.15 +
            (screen.height * 0.31 - screen.height * 0.15) * logoDrop;

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: logoTop,
              left: 22,
              right: 22,
              child: Hero(
                tag: HeroTags.titleLogo,
                child: TicTacToeTitleLogo(fontSize: logoFontSize),
              ),
            ),
            _LoadingContent(
              topOffset: screen.height * 0.49,
              fadeIn: contentIn,
              title: title,
              beamProgress: progress,
            ),
            _LoadingFooter(
              bottomOffset: MediaQuery.paddingOf(context).bottom + 34,
              fadeIn: footerIn,
              text: footer,
            ),
          ],
        );
      },
    );
  }
}

class _LoadingSigil extends StatelessWidget {
  const _LoadingSigil({required this.animation, required this.size});

  final Animation<double> animation;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.36),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = animation.value;
          final opacity = (0.2 + progress * 0.42).clamp(0.0, 0.62);

          return Transform.scale(
            scale: 0.97 + progress * 0.05,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(opacity: opacity, child: child),
                SizedBox.square(
                  dimension: size * 0.52,
                  child: CustomPaint(painter: _SealRingPainter(progress)),
                ),
              ],
            ),
          );
        },
        child: SigilBackdrop(height: size),
      ),
    );
  }
}

class _SealRingPainter extends CustomPainter {
  const _SealRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final eased = Curves.easeInOutCubic.transform(progress);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppPalette.gold.withValues(alpha: AppAlphas.subtle);
    canvas.drawCircle(center, radius, track);
    canvas.drawCircle(center, radius * 0.9, track);

    final seal = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6
      ..color = AppPalette.goldBright.withValues(alpha: AppAlphas.prominent)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * eased,
      false,
      seal,
    );

    final tick = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4
      ..color = AppPalette.gold.withValues(alpha: AppAlphas.muted);
    const count = 24;
    final rotation = eased * math.pi * 0.5;
    for (var index = 0; index < count; index++) {
      final angle = rotation + index * math.pi * 2 / count;
      final inner = index.isEven ? radius * 0.9 : radius * 0.94;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * inner,
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SealRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent({
    required this.topOffset,
    required this.fadeIn,
    required this.title,
    required this.beamProgress,
  });

  final double topOffset;
  final double fadeIn;
  final String title;
  final double beamProgress;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: fadeIn,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - fadeIn)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const RuneDiamond(size: 4),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: GildedText(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: AppPalette.titleFont,
                        fontSize: 18,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const RuneDiamond(size: 4),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LoadingBeam(progress: beamProgress),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingFooter extends StatelessWidget {
  const _LoadingFooter({
    required this.bottomOffset,
    required this.fadeIn,
    required this.text,
  });

  final double bottomOffset;
  final double fadeIn;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 28,
      right: 28,
      bottom: bottomOffset,
      child: Opacity(
        opacity: fadeIn,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppPalette.gold.withValues(alpha: 0.46),
            fontFamily: AppPalette.serifFont,
            fontSize: 12,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
