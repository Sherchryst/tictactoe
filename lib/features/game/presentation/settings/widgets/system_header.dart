import 'package:flutter/material.dart';
import 'package:tictactoe/core/assets/app_assets.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/design_system/widgets/app_pressable.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';

class SystemHeader extends StatelessWidget {
  const SystemHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);
    final copy = GameCopy.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 18,
        compact ? 8 : 12,
        compact ? 10 : 18,
        4,
      ),
      child: Row(
        children: [
          _HeaderPlate(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeaderSigil(compact: compact),
                SizedBox(width: compact ? 9 : 12),
                _HeaderTitle(text: copy.systemHeaderTitle, compact: compact),
              ],
            ),
          ),
          const Spacer(),
          AppPressable(
            onTap: onBack,
            semanticLabel: copy.backTooltip,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.close_rounded,
                color: AppPalette.ivoryText.withValues(alpha: AppAlphas.strong),
                size: compact ? 24 : 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPlate extends StatelessWidget {
  const _HeaderPlate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppPalette.ivoryText.withValues(alpha: AppAlphas.soft),
            AppPalette.ivoryText.withValues(alpha: AppAlphas.faint),
            const Color(0x00000000),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 6, compact ? 28 : 48, 6),
        child: child,
      ),
    );
  }
}

class _HeaderSigil extends StatelessWidget {
  const _HeaderSigil({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.ivoryText.withValues(alpha: 0.1),
        border: Border.all(
          color: AppPalette.ivoryText.withValues(alpha: AppAlphas.muted),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 7 : 8),
        child: Image.asset(
          AppAssets.sigil,
          height: compact ? 24 : 30,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.text, required this.compact});

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          (compact
                  ? Theme.of(context).textTheme.titleLarge
                  : Theme.of(context).textTheme.headlineSmall)
              ?.copyWith(
                color: AppPalette.ivoryText,
                fontFamily: AppPalette.serifFont,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
                shadows: const [Shadow(blurRadius: 12)],
              ),
    );
  }
}
