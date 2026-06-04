import 'dart:developer' as developer;

final class AppLogger {
  const AppLogger._();

  static const _appName = 'tictactoe';

  static void debug(
    String message, {
    String name = _appName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(message, level: 500, name: name, error: error, stackTrace: stackTrace);
  }

  static void info(
    String message, {
    String name = _appName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(message, level: 800, name: name, error: error, stackTrace: stackTrace);
  }

  static void warning(
    String message, {
    String name = _appName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(message, level: 900, name: name, error: error, stackTrace: stackTrace);
  }

  static void error(
    String message, {
    String name = _appName,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      message,
      level: 1000,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(
    String message, {
    required int level,
    required String name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      level: level,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
