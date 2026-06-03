part of 'game_board.dart';

class _GameCell extends HookWidget {
  const _GameCell({
    required this.cell,
    required this.highlighted,
    required this.enabled,
    required this.onPressed,
  });

  final Cell cell;
  final bool highlighted;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final pressed = useState(false);

    void setPressed(bool value) {
      void applyPressed() {
        if (!context.mounted || pressed.value == value) {
          return;
        }

        pressed.value = value;
      }

      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) => applyPressed());
      } else {
        applyPressed();
      }
    }

    return Semantics(
      button: enabled,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setPressed(true) : null,
          onTapCancel: enabled ? () => setPressed(false) : null,
          onTapUp: enabled
              ? (_) {
                  setPressed(false);
                  unawaited(AppHaptics.markPlaced());
                  onPressed();
                }
              : null,
          child: AnimatedScale(
            duration: AppDurations.micro,
            curve: AppCurves.entrance,
            scale: pressed.value ? 0.96 : 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (highlighted)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppPalette.gold.withValues(alpha: AppAlphas.soft),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                RepaintBoundary(child: _Mark(cell: cell)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkHalo extends StatelessWidget {
  const _MarkHalo();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppPalette.goldBright.withValues(alpha: AppAlphas.medium),
            AppPalette.gold.withValues(alpha: AppAlphas.faint),
            const Color(0x00000000),
          ],
          stops: const [0, 0.45, 1],
        ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.cell});

  final Cell cell;

  @override
  Widget build(BuildContext context) {
    final asset = switch (cell) {
      Cell.human => AppAssets.markX,
      Cell.cpu => AppAssets.markO,
      Cell.empty => null,
    };

    if (asset == null) {
      return const SizedBox.shrink();
    }

    final isGold = cell == Cell.cpu;
    final slashAngle = cell == Cell.human ? -math.pi / 12 : math.pi / 12;

    return TweenAnimationBuilder<double>(
      key: ValueKey(asset),
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.boardMarkReveal,
      curve: AppCurves.entrance,
      builder: (context, value, child) {
        final markScale = value < 0.72
            ? 0.72 + value / 0.72 * 0.32
            : 1.04 - (value - 0.72) / 0.28 * 0.04;

        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -8 * (1 - value)),
            child: Transform.scale(scale: markScale, child: child),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          const FractionallySizedBox(
            widthFactor: 0.92,
            heightFactor: 0.92,
            child: _MarkHalo(),
          ),
          const _ImpactFlash(),
          _SlashEffect(isGold: isGold, angle: slashAngle),
          _ParticleRing(isGold: isGold),
          FractionallySizedBox(
            widthFactor: cell == Cell.human ? 0.58 : 0.62,
            heightFactor: cell == Cell.human ? 0.58 : 0.62,
            child: Image.asset(asset, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
