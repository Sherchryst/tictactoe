import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_spacing.dart';
import 'package:tictactoe/core/design_system/widgets/tic_tac_toe_title_logo.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class EndingCreditsContent extends StatelessWidget {
  const EndingCreditsContent({required this.compact, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final music = [
      l10n.creditsMusicRecusants,
      l10n.creditsMusicRadahn,
      l10n.creditsMusicMohg,
      l10n.creditsMusicMalenia,
    ];
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: AppPalette.goldBright,
      fontFamily: AppPalette.titleFont,
      fontSize: compact ? 27 : 34,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      shadows: [
        Shadow(
          color: AppPalette.gold.withValues(alpha: AppAlphas.medium),
          blurRadius: 18,
        ),
      ],
    );
    final sectionStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: AppPalette.goldBright.withValues(alpha: 0.92),
      fontFamily: AppPalette.titleFont,
      fontSize: compact ? 17 : 20,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppPalette.ivoryText.withValues(alpha: 0.86),
      fontFamily: AppPalette.titleFont,
      fontSize: compact ? 14 : 16,
      height: 1.55,
      letterSpacing: 0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TicTacToeTitleLogo(title: l10n.appTitle, fontSize: compact ? 46 : 62),
        SizedBox(height: compact ? AppSpacing.xxl : AppSpacing.xxxl),
        Text(
          l10n.noMercyAction,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: titleStyle,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _CreditSection(
          title: l10n.creditsConceptTitle,
          lines: [l10n.creditsDesignerName],
          sectionStyle: sectionStyle,
          bodyStyle: bodyStyle,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _CreditSection(
          title: l10n.creditsMusicTitle,
          lines: music,
          sectionStyle: sectionStyle,
          bodyStyle: bodyStyle,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _CreditSection(
          title: l10n.creditsEldenRingTitle,
          lines: [
            l10n.creditsCopyrightFromSoftware,
            l10n.creditsCopyrightBandaiNamco,
          ],
          sectionStyle: sectionStyle,
          bodyStyle: bodyStyle,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          l10n.creditsThanks,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: sectionStyle,
        ),
      ],
    );
  }
}

class _CreditSection extends StatelessWidget {
  const _CreditSection({
    required this.title,
    required this.lines,
    required this.sectionStyle,
    required this.bodyStyle,
  });

  final String title;
  final List<String> lines;
  final TextStyle? sectionStyle;
  final TextStyle? bodyStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: sectionStyle,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final line in lines)
          Text(
            line,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: bodyStyle,
          ),
      ],
    );
  }
}
