import 'package:flutter/widgets.dart';

final class AppRadius {
  const AppRadius._();

  static const double small = 4;
  static const double medium = 8;
  static const double large = 12;

  static const BorderRadius dialog = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius button = BorderRadius.all(Radius.circular(medium));
}
