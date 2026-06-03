import 'package:flutter/animation.dart';

final class AppAnimations {
  const AppAnimations._();

  static double interval(
    double value, {
    required double begin,
    required double end,
    required Curve curve,
  }) {
    if (begin >= end) {
      return curve.transform(value.clamp(0.0, 1.0));
    }

    final normalized = ((value - begin) / (end - begin)).clamp(0.0, 1.0);
    return curve.transform(normalized);
  }
}
