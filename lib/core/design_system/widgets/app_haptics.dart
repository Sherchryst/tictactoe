import 'package:flutter/services.dart';

final class AppHaptics {
  const AppHaptics._();

  static Future<void> menuSelect() {
    return HapticFeedback.selectionClick();
  }

  static Future<void> markPlaced() {
    return HapticFeedback.lightImpact();
  }

  static Future<void> outcome() {
    return HapticFeedback.heavyImpact();
  }
}
