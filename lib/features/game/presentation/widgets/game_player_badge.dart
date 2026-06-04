import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/core/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/participant.dart';
import 'package:tictactoe/features/game/presentation/utils/bosses/boss_glow_palette.dart';
import 'package:tictactoe/features/game/presentation/utils/bosses/boss_presentation.dart';
import 'package:tictactoe/features/game/presentation/utils/styles/game_player_badge_types.dart';
import 'package:tictactoe/features/game/presentation/utils/text/player_label_resolver.dart';
import 'package:tictactoe/features/game/presentation/widgets/boss_rune_card.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_player_badge_label.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

const _compactMedallionSize = 52.0;
const _regularMedallionSize = 64.0;

class GamePlayerBadge extends StatelessWidget {
  const GamePlayerBadge({
    required this.participant,
    required this.session,
    required this.active,
    required this.side,
    this.visible = true,
    super.key,
  });

  final GameParticipant participant;
  final GameSession session;
  final bool active;
  final GamePlayerBadgeSide side;
  final bool visible;

  static double medallionDimensionFor(BuildContext context) {
    return AppBreakpoints.isCompact(context)
        ? _compactMedallionSize
        : _regularMedallionSize;
  }

  @override
  Widget build(BuildContext context) {
    final compact = AppBreakpoints.isCompact(context);
    final labels = PlayerLabelResolver(AppLocalizations.of(context));
    final tone = _toneFor(participant, active);
    final medallion = _Medallion(
      emblem: _emblemFor(participant),
      glowPalette: _glowPaletteFor(participant),
      tone: tone,
    );
    final splitBossName = switch (participant) {
      CpuParticipant(:final bossId) => bossId.isNoMercy,
      HumanParticipant() => false,
    };
    final label = Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        ),
        child: GamePlayerBadgeNameLabel(
          name: labels.badgeName(participant, session),
          tone: tone,
          side: side,
          splitBossName: splitBossName,
        ),
      ),
    );
    final children = side == GamePlayerBadgeSide.left
        ? [medallion, label]
        : [label, medallion];

    return Opacity(
      opacity: visible ? 1 : 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: compact ? 370 : 420),
        child: Row(children: children),
      ),
    );
  }

  BossGlowPalette _glowPaletteFor(GameParticipant participant) {
    return switch (participant) {
      CpuParticipant(:final bossId) => bossId.presentation.glowPalette,
      HumanParticipant() => BossGlowPalette.guided,
    };
  }

  String _emblemFor(GameParticipant participant) {
    return switch (participant) {
      CpuParticipant(:final bossId)
          when session.isNoMercy &&
              session.participantOutcome == GameOutcome.humanWin =>
        bossId.presentation.deadAsset,
      CpuParticipant(:final bossId) => bossId.presentation.emblemAsset,
      HumanParticipant() when session.isNoMercy => AppAssets.runeArc,
      HumanParticipant(:final mark) =>
        mark == session.humanMark ? AppAssets.flask : AppAssets.runeArc,
    };
  }

  GamePlayerBadgeTone _toneFor(GameParticipant participant, bool active) {
    if (participant.kind == ParticipantKind.cpu) {
      return GamePlayerBadgeTone.hostile;
    }

    return active ? GamePlayerBadgeTone.active : GamePlayerBadgeTone.idle;
  }
}

class _Medallion extends StatelessWidget {
  const _Medallion({
    required this.emblem,
    required this.glowPalette,
    required this.tone,
  });

  final String emblem;
  final BossGlowPalette glowPalette;
  final GamePlayerBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final dimension = GamePlayerBadge.medallionDimensionFor(context);
    final prominent = tone != GamePlayerBadgeTone.idle;
    final hostile = tone == GamePlayerBadgeTone.hostile;

    return SizedBox(
      width: dimension,
      height: dimension,
      child: BossRuneCard(
        asset: emblem,
        prominent: prominent,
        hostile: hostile,
        glowPalette: glowPalette,
      ),
    );
  }
}
