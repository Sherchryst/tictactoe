import 'package:flutter/material.dart';

import 'package:tictactoe/design_system/widgets/app_error_state.dart';
import 'package:tictactoe/design_system/widgets/app_loading_indicator.dart';

class SystemLoadingState extends StatelessWidget {
  const SystemLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: AppLoadingIndicator(size: 48));
  }
}

class SystemEmptyState extends StatelessWidget {
  const SystemEmptyState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(message: message);
  }
}
