import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('game and settings do not import each other directly', () {
    final violations = <String>[];

    for (final file in _dartFiles(Directory('lib/features/game'))) {
      final content = file.readAsStringSync();
      if (content.contains('package:tictactoe/features/settings/')) {
        violations.add(file.path);
      }
    }

    for (final file in _dartFiles(Directory('lib/features/settings'))) {
      final content = file.readAsStringSync();
      if (content.contains('package:tictactoe/features/game/')) {
        violations.add(file.path);
      }
    }

    expect(violations, isEmpty);
  });
}

Iterable<File> _dartFiles(Directory directory) {
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('.g.dart'))
      .where((file) => !file.path.endsWith('.freezed.dart'));
}
