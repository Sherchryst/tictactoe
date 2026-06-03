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

enum _Side { left, right }

const _compactMedallionSize = 30.0;
const _regularMedallionSize = 34.0;

class DuelRibbon extends StatelessWidget {
  const DuelRibbon({required this.activePlayer, required this.mode, super.key});

  final Player? activePlayer;
  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);
    final playerLabels = PlayerLabelResolver(AppLocalizations.of(context));

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final minimumCenterGap = compact ? AppSpacing.xxl : AppSpacing.xxxl;
          final maximumEntryWidth = ((availableWidth - minimumCenterGap) / 2)
              .clamp(0.0, compact ? 172.0 : 226.0)
              .toDouble();
          final entryWidth = (availableWidth * (compact ? 0.36 : 0.34))
              .clamp(0.0, maximumEntryWidth)
              .toDouble();

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: entryWidth,
                child: _RosterEntry(
                  side: _Side.left,
                  emblem: AppAssets.flask,
                  name: playerLabels.score(Player.human, mode),
                  active: activePlayer == Player.human,
                ),
              ),
              SizedBox(
                width: entryWidth,
                child: _RosterEntry(
                  side: _Side.right,
                  emblem: AppAssets.runeArc,
                  name: playerLabels.score(Player.cpu, mode),
                  active: activePlayer == Player.cpu,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RosterEntry extends StatelessWidget {
  const _RosterEntry({
    required this.side,
    required this.emblem,
    required this.name,
    required this.active,
  });

  final _Side side;
  final String emblem;
  final String name;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);
    final medallion = _Medallion(emblem: emblem, active: active);
    final label = Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        ),
        child: _NameLabel(name: name, active: active, side: side),
      ),
    );

    final children = side == _Side.left
        ? [medallion, label]
        : [label, medallion];

    return Row(children: children);
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
  final _Side side;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.of(context).chromeMark(active: active);
    final align = side == _Side.left ? TextAlign.left : TextAlign.right;

    return active
        ? GildedText(
            name,
            textAlign: align,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          )
        : Text(
            name,
            textAlign: align,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          );
  }
}
