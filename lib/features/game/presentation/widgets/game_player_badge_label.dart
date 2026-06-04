import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_typography.dart';
import 'package:tictactoe/core/design_system/widgets/gilded_text.dart';
import 'package:tictactoe/features/game/presentation/utils/styles/game_player_badge_types.dart';

class GamePlayerBadgeNameLabel extends StatelessWidget {
  const GamePlayerBadgeNameLabel({
    required this.name,
    required this.tone,
    required this.side,
    required this.splitBossName,
    super.key,
  });

  final String name;
  final GamePlayerBadgeTone tone;
  final GamePlayerBadgeSide side;
  final bool splitBossName;

  @override
  Widget build(BuildContext context) {
    final hostile = tone == GamePlayerBadgeTone.hostile;
    final active = tone == GamePlayerBadgeTone.active;
    final style = AppTypography.of(
      context,
    ).chromeMark(active: tone != GamePlayerBadgeTone.idle);
    final textAlign = side == GamePlayerBadgeSide.left
        ? TextAlign.left
        : TextAlign.right;
    final boxAlignment = side == GamePlayerBadgeSide.left
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final hostileStyle = style?.copyWith(
      color: AppPalette.lossRed.withValues(alpha: AppAlphas.opaque),
      fontSize: 16,
      letterSpacing: 0,
      shadows: [
        Shadow(
          color: AppPalette.lossRed.withValues(alpha: AppAlphas.medium),
          blurRadius: 12,
        ),
      ],
    );
    final bossName = splitBossName ? _BossNameText.from(name) : null;
    final text = hostile && bossName != null
        ? RichText(
            textAlign: textAlign,
            overflow: TextOverflow.visible,
            maxLines: 2,
            text: TextSpan(
              style: hostileStyle,
              children: [
                TextSpan(text: bossName.name),
                if (bossName.title.isNotEmpty)
                  TextSpan(
                    text: '\n${bossName.title}',
                    style: hostileStyle?.copyWith(
                      color: AppPalette.ivoryText.withValues(alpha: 0.86),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          )
        : hostile
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

final class _BossNameText {
  const _BossNameText({required this.name, required this.title});

  factory _BossNameText.from(String label) {
    final base = label;
    final comma = base.indexOf(',');

    if (comma > -1) {
      return _BossNameText(
        name: base.substring(0, comma).trim(),
        title: base.substring(comma + 1).trim(),
      );
    }

    final words = base.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    if (words.length < 2) {
      return _BossNameText(name: base.trim(), title: '');
    }

    return _BossNameText(
      name: words.last,
      title: words.take(words.length - 1).join(' '),
    );
  }

  final String name;
  final String title;
}
