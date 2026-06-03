import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_alphas.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/core/design_system/tokens/app_typography.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_row_chrome.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class SystemToggleRow extends StatelessWidget {
  const SystemToggleRow({
    required this.index,
    required this.selected,
    required this.label,
    required this.value,
    required this.onFocus,
    required this.onChanged,
    super.key,
  });

  final int index;
  final bool selected;
  final String label;
  final bool value;
  final ValueChanged<int> onFocus;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    void handleTap() {
      onFocus(index);
      onChanged(!value);
    }

    return SystemRowChrome(
      selected: selected,
      onTap: handleTap,
      child: Row(
        children: [
          Expanded(
            child: SystemRowLabel(label: label, selected: selected),
          ),
          _SystemToggleValue(selected: selected, enabled: value),
        ],
      ),
    );
  }
}

class _SystemToggleValue extends StatelessWidget {
  const _SystemToggleValue({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final copy = AppLocalizations.of(context);
    final color = enabled
        ? AppPalette.goldBright
        : AppPalette.ivoryText.withValues(alpha: 0.5);

    return AnimatedContainer(
      duration: AppDurations.short,
      curve: Curves.easeOutCubic,
      width: 74,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppPalette.backgroundDeep.withValues(alpha: 0.3),
        border: Border.all(
          color: selected
              ? color.withValues(alpha: 0.78)
              : AppPalette.ivoryText.withValues(alpha: AppAlphas.soft),
        ),
      ),
      child: Text(
        enabled ? copy.onLabel : copy.offLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.of(context).toggleValue(enabled: enabled),
      ),
    );
  }
}

class SystemSliderRow extends StatelessWidget {
  const SystemSliderRow({
    required this.index,
    required this.selected,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onFocus,
    required this.onChanged,
    super.key,
  });

  final int index;
  final bool selected;
  final String label;
  final double value;
  final bool enabled;
  final ValueChanged<int> onFocus;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    final compact = AppBreakpoints.isCompact(context);
    final slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppPalette.ivoryText.withValues(
          alpha: selected ? 0.92 : 0.66,
        ),
        inactiveTrackColor: AppPalette.ivoryText.withValues(
          alpha: AppAlphas.soft,
        ),
        thumbColor: AppPalette.goldBright,
        overlayShape: SliderComponentShape.noOverlay,
        trackHeight: 2,
      ),
      child: Slider(
        value: value,
        onChanged: enabled
            ? (next) {
                onFocus(index);
                onChanged(next);
              }
            : null,
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.44,
      child: SystemRowChrome(
        selected: selected,
        onTap: () => onFocus(index),
        child: compact
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SystemRowLabel(label: label, selected: selected),
                      ),
                      _PercentText(percent: percent),
                    ],
                  ),
                  SizedBox(height: 36, child: slider),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: SystemRowLabel(label: label, selected: selected),
                  ),
                  Expanded(child: slider),
                  _PercentText(percent: percent),
                ],
              ),
      ),
    );
  }
}

class _PercentText extends StatelessWidget {
  const _PercentText({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Text(
        percent.toString(),
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppPalette.ivoryText.withValues(alpha: 0.82),
          fontFamily: AppPalette.serifFont,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class SystemMetricRow extends StatelessWidget {
  const SystemMetricRow({
    required this.index,
    required this.selected,
    required this.label,
    required this.value,
    required this.onFocus,
    super.key,
  });

  final int index;
  final bool selected;
  final String label;
  final String value;
  final ValueChanged<int> onFocus;

  @override
  Widget build(BuildContext context) {
    return SystemRowChrome(
      selected: selected,
      onTap: () => onFocus(index),
      child: Row(
        children: [
          Image.asset(
            AppAssets.statusRune,
            height: 22,
            opacity: AlwaysStoppedAnimation(selected ? 0.94 : 0.58),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SystemRowLabel(label: label, selected: selected),
          ),
          Text(value, style: AppTypography.of(context).metricValue()),
        ],
      ),
    );
  }
}

class SystemActionRow extends StatelessWidget {
  const SystemActionRow({
    required this.index,
    required this.selected,
    required this.label,
    required this.value,
    required this.onFocus,
    required this.onPressed,
    super.key,
  });

  final int index;
  final bool selected;
  final String label;
  final String value;
  final ValueChanged<int> onFocus;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SystemRowChrome(
      selected: selected,
      onTap: () {
        onFocus(index);
        onPressed();
      },
      child: Row(
        children: [
          Expanded(
            child: SystemRowLabel(label: label, selected: selected),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppPalette.ivoryText.withValues(
                  alpha: AppAlphas.prominent,
                ),
                fontFamily: AppPalette.serifFont,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SystemLanguageRow extends StatelessWidget {
  const SystemLanguageRow({
    required this.index,
    required this.selected,
    required this.active,
    required this.label,
    required this.onFocus,
    required this.onPressed,
    super.key,
  });

  final int index;
  final bool selected;
  final bool active;
  final String label;
  final ValueChanged<int> onFocus;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SystemRowChrome(
      selected: selected,
      onTap: () {
        onFocus(index);
        onPressed();
      },
      child: Row(
        children: [
          Expanded(
            child: SystemRowLabel(label: label, selected: selected),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            opacity: active ? 1 : 0,
            child: Icon(
              Icons.check_rounded,
              color: AppPalette.goldBright.withValues(alpha: AppAlphas.opaque),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
