import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/widgets/page_frame.dart';
import '../../../game/domain/entities/app_theme_preference.dart';
import '../../../game/presentation/game_copy.dart';
import '../../../game/presentation/widgets/scoreboard_summary.dart';
import '../controllers/settings_controller.dart';
import '../controllers/settings_view_state.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(GameCopy.settingsTitle),
        leading: IconButton(
          tooltip: GameCopy.backTooltip,
          onPressed: () => context.go(AppRoutes.homeLocation),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: PageFrame(
        child: settings.when(
          data: (state) => _SettingsContent(state: state),
          error: (_, _) =>
              const Center(child: Text(GameCopy.settingsLoadError)),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  const _SettingsContent({required this.state});

  final SettingsViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(settingsControllerProvider.notifier);

    return ListView(
      children: [
        Text(
          GameCopy.themeTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SegmentedButton<AppThemePreference>(
          segments: const [
            ButtonSegment(
              value: AppThemePreference.system,
              label: Text(GameCopy.systemThemeLabel),
              icon: Icon(Icons.brightness_auto_outlined),
            ),
            ButtonSegment(
              value: AppThemePreference.light,
              label: Text(GameCopy.lightThemeLabel),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: AppThemePreference.dark,
              label: Text(GameCopy.darkThemeLabel),
              icon: Icon(Icons.dark_mode_outlined),
            ),
          ],
          selected: {state.settings.themePreference},
          onSelectionChanged: (selection) =>
              unawaited(controller.setThemePreference(selection.single)),
        ),
        const SizedBox(height: 32),
        Text(
          GameCopy.scoreTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ScoreboardSummary(
          scoreboard: state.scoreboard,
          mode: state.settings.mode,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => unawaited(controller.resetScoreboard()),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text(GameCopy.resetScoreAction),
        ),
      ],
    );
  }
}
