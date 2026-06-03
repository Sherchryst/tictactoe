# Test Architecture

Tests follow the application layers:

- `features/*/domain`: pure entity, service, and use case tests. Mock domain ports or collaborators with reusable Mockito mocks from `package:tictactoe/testing/mocks.mocks.dart`.
- `features/*/data`: repository and data source tests. Mock external ports such as storage when checking interactions, but prefer in-memory storage when testing serialization and persistence behavior end to end.
- `features/*/presentation`: Flutter and Riverpod state tests. Build `ProviderContainer` instances with `package:tictactoe/testing/provider_container_factory.dart` and override providers at the layer boundary.

Shared test doubles live in `lib/testing/` and are imported with `package:tictactoe/testing/...`:

- `mocks.dart`: Mockito mock declarations. Regenerate `mocks.mocks.dart` with `dart run build_runner build`.
- `mock_stubs.dart`: common stubbing for generated mocks.
- `cpu_strategy_stubs.dart`: deterministic non-Mockito stubs for scenario tests that need queued CPU moves.
