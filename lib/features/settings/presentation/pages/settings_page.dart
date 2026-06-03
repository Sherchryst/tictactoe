import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/design_system/tokens/app_breakpoints.dart';
import 'package:tictactoe/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tictactoe/features/settings/presentation/widgets/settings_content.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_backdrop.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_category.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_footer.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_header.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_states.dart';
import 'package:tictactoe/features/settings/presentation/widgets/system_window.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({required this.onBack, this.onCategoryChanged, super.key});

  final VoidCallback onBack;
  final VoidCallback? onCategoryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final copy = AppLocalizations.of(context);
    final category = useState(SystemCategory.audio);
    final focusedRowIndex = useState(0);
    final compact = AppBreakpoints.isCompact(context);

    void selectCategory(SystemCategory nextCategory) {
      if (category.value == nextCategory) {
        return;
      }

      category.value = nextCategory;
      focusedRowIndex.value = 0;
      final handleCategoryChanged = onCategoryChanged;
      if (handleCategoryChanged != null) {
        handleCategoryChanged();
      }
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SystemBackdrop(),
          SafeArea(
            child: Column(
              children: [
                SystemHeader(onBack: onBack),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 10 : 18,
                          compact ? 8 : 10,
                          compact ? 10 : 18,
                          compact ? 8 : 12,
                        ),
                        child: SystemWindow(
                          title: category.value.title(copy),
                          selectedCategory: category.value,
                          onCategorySelected: selectCategory,
                          child: settings.when(
                            data: (state) => SettingsContent(
                              state: state,
                              category: category.value,
                              focusedRowIndex: focusedRowIndex.value,
                              onFocusRow: (index) {
                                if (focusedRowIndex.value != index) {
                                  focusedRowIndex.value = index;
                                }
                              },
                            ),
                            error: (_, _) => SystemEmptyState(
                              message: copy.settingsLoadError,
                            ),
                            loading: () => const SystemLoadingState(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SystemFooter(
                  helpText: category.value.helpText(
                    copy,
                    focusedRowIndex.value,
                  ),
                  onBack: onBack,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
