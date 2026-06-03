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

enum _BadgeTone { active, idle, hostile }

const _compactMedallionSize = 30.0;
const _regularMedallionSize = 34.0;
const _soloOpponentLabel = 'Malenia, Blade of Miquella';

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
    final tone = _toneFor(player, mode, active);
    final medallion = _Medallion(emblem: _emblemFor(player, mode), tone: tone);
    final label = Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        ),
        child: _NameLabel(
          name: _labelFor(labels, player, mode),
          tone: tone,
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

  String _labelFor(PlayerLabelResolver labels, Player player, GameMode mode) {
    if (mode == GameMode.humanVsCpu && player == Player.cpu) {
      return _soloOpponentLabel;
    }
    return labels.badgeName(player, mode);
  }

  String _emblemFor(Player player, GameMode mode) {
    if (mode == GameMode.humanVsCpu && player == Player.cpu) {
      return AppAssets.malenia;
    }

    return switch (player) {
      Player.human => AppAssets.flask,
      Player.cpu => AppAssets.runeArc,
    };
  }

  _BadgeTone _toneFor(Player player, GameMode mode, bool active) {
    if (mode == GameMode.humanVsCpu && player == Player.cpu) {
      return _BadgeTone.hostile;
    }

    return active ? _BadgeTone.active : _BadgeTone.idle;
  }
}

class _Medallion extends StatelessWidget {
  const _Medallion({required this.emblem, required this.tone});

  final String emblem;
  final _BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);
    final dimension = compact ? _compactMedallionSize : _regularMedallionSize;
    final prominent = tone != _BadgeTone.idle;
    final hostile = tone == _BadgeTone.hostile;

    return AnimatedContainer(
      duration: AppDurations.short,
      curve: Curves.easeOutCubic,
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            (hostile ? AppPalette.emberRed : AppPalette.surfaceRaised)
                .withValues(
                  alpha: prominent ? AppAlphas.medium : AppAlphas.subtle,
                ),
            const Color(0x00000000),
          ],
        ),
        border: Border.all(
          color: (hostile ? AppPalette.lossRed : AppPalette.gold).withValues(
            alpha: prominent ? AppAlphas.prominent : AppAlphas.muted,
          ),
          width: prominent ? 1.4 : 1,
        ),
        boxShadow: prominent
            ? [
                BoxShadow(
                  color: (hostile ? AppPalette.lossRed : AppPalette.gold)
                      .withValues(alpha: AppAlphas.medium),
                  blurRadius: hostile ? 18 : 14,
                  spreadRadius: hostile ? 1 : 0,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Image.asset(
          emblem,
          fit: BoxFit.contain,
          opacity: AlwaysStoppedAnimation(prominent ? 1 : 0.6),
        ),
      ),
    );
  }
}

class _NameLabel extends StatelessWidget {
  const _NameLabel({
    required this.name,
    required this.tone,
    required this.side,
  });

  final String name;
  final _BadgeTone tone;
  final GamePlayerBadgeSide side;

  @override
  Widget build(BuildContext context) {
    final hostile = tone == _BadgeTone.hostile;
    final active = tone == _BadgeTone.active;
    final style = AppTypography.of(
      context,
    ).chromeMark(active: tone != _BadgeTone.idle);
    final textAlign = side == GamePlayerBadgeSide.left
        ? TextAlign.left
        : TextAlign.right;
    final boxAlignment = side == GamePlayerBadgeSide.left
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final hostileStyle = style?.copyWith(
      color: AppPalette.lossRed.withValues(alpha: AppAlphas.opaque),
      shadows: [
        Shadow(
          color: AppPalette.lossRed.withValues(alpha: AppAlphas.medium),
          blurRadius: 12,
        ),
      ],
    );
    final text = hostile
        ? Text(
            name,
            textAlign: textAlign,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: hostileStyle,
          )
        : active
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
