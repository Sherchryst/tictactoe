import 'package:flutter/material.dart';

class ActionDialog extends StatelessWidget {
  const ActionDialog({
    required this.title,
    required this.message,
    required this.actions,
    super.key,
  });

  final String title;
  final String message;
  final List<ActionDialogButton> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(message, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 28),
              for (final (index, action) in actions.indexed) ...[
                if (index > 0) const SizedBox(height: 12),
                _ActionButton(action: action),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ActionDialogButton {
  const ActionDialogButton({
    required this.label,
    required this.onPressed,
    this.prominent = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool prominent;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final ActionDialogButton action;

  @override
  Widget build(BuildContext context) {
    final style = action.prominent
        ? FilledButton.styleFrom(minimumSize: const Size.fromHeight(48))
        : OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48));

    if (action.prominent) {
      return FilledButton(
        onPressed: action.onPressed,
        style: style,
        child: Text(action.label),
      );
    }

    return OutlinedButton(
      onPressed: action.onPressed,
      style: style,
      child: Text(action.label),
    );
  }
}
