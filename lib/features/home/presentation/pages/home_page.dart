import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui/widgets/action_dialog.dart';
import '../../../../core/ui/widgets/page_frame.dart';
import '../../../game/domain/entities/game_difficulty.dart';
import '../../../game/domain/entities/game_mode.dart';
import '../../../game/domain/entities/game_settings.dart';
import '../../../game/presentation/controllers/game_controller.dart';
import '../../../game/presentation/game_copy.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: PageFrame(
        maxWidth: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text(
              GameCopy.appTitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 64),
            _ModeButton(
              icon: Icons.groups_rounded,
              label: GameCopy.localGameAction,
              onPressed: () => _startGame(
                context,
                ref,
                const GameSettings(mode: GameMode.humanVsHuman),
              ),
            ),
            const SizedBox(height: 16),
            _ModeButton(
              icon: Icons.smart_toy_rounded,
              label: GameCopy.aiGameAction,
              filled: true,
              onPressed: () => _chooseAiDifficulty(context, ref),
            ),
            const SizedBox(height: 28),
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.settingsLocation),
              icon: const Icon(Icons.tune_rounded),
              label: const Text(GameCopy.settingsTitle),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseAiDifficulty(BuildContext context, WidgetRef ref) async {
    final difficulty = await showDialog<GameDifficulty>(
      context: context,
      builder: (context) => const _DifficultyDialog(),
    );

    if (!context.mounted || difficulty == null) {
      return;
    }

    await _startGame(context, ref, GameSettings(difficulty: difficulty));
  }

  Future<void> _startGame(
    BuildContext context,
    WidgetRef ref,
    GameSettings settings,
  ) async {
    ref.read(gameControllerProvider.notifier).startGame(settings);
    unawaited(
      ref.read(settingsControllerProvider.notifier).setGameSettings(settings),
    );

    if (context.mounted) {
      context.go(AppRoutes.gameLocation);
    }
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      child: child,
    );
  }
}

class _DifficultyDialog extends StatelessWidget {
  const _DifficultyDialog();

  @override
  Widget build(BuildContext context) {
    return ActionDialog(
      title: GameCopy.selectDifficultyTitle,
      message: GameCopy.selectDifficultyMessage,
      actions: [
        ActionDialogButton(
          label: GameCopy.easyLabel,
          onPressed: () => Navigator.of(context).pop(GameDifficulty.easy),
        ),
        ActionDialogButton(
          label: GameCopy.hardLabel,
          prominent: true,
          onPressed: () => Navigator.of(context).pop(GameDifficulty.hard),
        ),
      ],
    );
  }
}
