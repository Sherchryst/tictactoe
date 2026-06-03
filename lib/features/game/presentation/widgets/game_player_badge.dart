import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/core/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/core/design_system/tokens/app_typography.dart';
import 'package:tictactoe/core/design_system/widgets/gilded_text.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/presentation/utils/text/player_label_resolver.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

enum GamePlayerBadgeSide { left, right }

const _compactMedallionSize = 30.0;
const _regularMedallionSize = 34.0;

class GamePlayerBadge extends StatelessWidget {
  const GamePlayerBadge({
    required this.player,
    required this.mode,
    required this.active,
    required this.side,
    super.key,
  });

  final Player player;
  final GameMode mode;
  final bool active;
  final GamePlayerBadgeSide side;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);
    final labels = PlayerLabelResolver(AppLocalizations.of(context));
    final medallion = _Medallion(emblem: _emblemFor(player), active: active);
    final label = Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        ),
        child: _NameLabel(
          name: labels.badgeName(player, mode),
          active: active,
          side: side,
        ),
      ),
    );
    final children = side == GamePlayerBadgeSide.left
        ? [medallion, label]
        : [label, medallion];

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 330 : 360),
      child: Row(children: children),
    );
  }

  String _emblemFor(Player player) {
    return switch (player) {
      Player.human => AppAssets.flask,
      Player.cpu => AppAssets.runeArc,
    };
  }
}

class _Medallion extends StatelessWidget {
  const _Medallion({required this.emblem, required this.active});

  final String emblem;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);
    final dimension = compact ? _compactMedallionSize : _regularMedallionSize;

    return AnimatedContainer(
      duration: AppDurations.short,
      curve: Curves.easeOutCubic,
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppPalette.surfaceRaised.withValues(
              alpha: active ? AppAlphas.medium : AppAlphas.subtle,
            ),
            const Color(0x00000000),
          ],
        ),
        border: Border.all(
          color: AppPalette.gold.withValues(
            alpha: active ? AppAlphas.prominent : AppAlphas.muted,
          ),
          width: active ? 1.4 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppPalette.gold.withValues(alpha: AppAlphas.medium),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Image.asset(
          emblem,
          fit: BoxFit.contain,
          opacity: AlwaysStoppedAnimation(active ? 1 : 0.6),
        ),
      ),
    );
  }
}

class _NameLabel extends StatelessWidget {
  const _NameLabel({
    required this.name,
    required this.active,
    required this.side,
  });

  final String name;
  final bool active;
  final GamePlayerBadgeSide side;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.of(context).chromeMark(active: active);
    final textAlign = side == GamePlayerBadgeSide.left
        ? TextAlign.left
        : TextAlign.right;
    final boxAlignment = side == GamePlayerBadgeSide.left
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final text = active
        ? GildedText(
            name,
            textAlign: textAlign,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: style,
          )
        : Text(
            name,
            textAlign: textAlign,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: style,
          );

    return Align(
      alignment: boxAlignment,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: boxAlignment,
        child: text,
      ),
    );
  }
}
