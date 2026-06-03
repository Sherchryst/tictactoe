import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef RegisterTearDown = void Function(FutureOr<void> Function());

ProviderContainer createTestContainer({
  dynamic overrides = const [],
  RegisterTearDown? registerTearDown,
}) {
  final container = ProviderContainer(overrides: overrides);
  registerTearDown?.call(container.dispose);
  return container;
}
