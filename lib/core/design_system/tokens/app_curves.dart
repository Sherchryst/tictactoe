import 'package:flutter/animation.dart';

final class AppCurves {
  const AppCurves._();

  static const Curve entrance = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.easeOutExpo;
  static const Curve shimmer = Curves.easeInOutSine;
}
