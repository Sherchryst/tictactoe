import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:tictactoe/core/router/app_routes.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_view_state.dart';

final class GameRouteAccessPolicy {
  const GameRouteAccessPolicy._();

  static bool shouldLeaveGameRoute({
    required GameViewState state,
    required bool enteredWithPlayableRound,
  }) {
    return !state.hasPreparedSession ||
        (!enteredWithPlayableRound && !state.session.result.isOngoing);
  }
}

class GameRouteGuard extends HookWidget {
  const GameRouteGuard({required this.state, required this.child, super.key});

  final GameViewState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enteredWithPlayableRound = useMemoized(
      () => state.session.result.isOngoing,
      const [],
    );
    final shouldLeave = GameRouteAccessPolicy.shouldLeaveGameRoute(
      state: state,
      enteredWithPlayableRound: enteredWithPlayableRound,
    );

    useEffect(() {
      if (!shouldLeave) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(AppRoutes.homeLocation);
        }
      });

      return null;
    }, [shouldLeave]);

    return shouldLeave ? const SizedBox.shrink() : child;
  }
}
