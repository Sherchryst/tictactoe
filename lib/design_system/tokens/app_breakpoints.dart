import 'package:flutter/widgets.dart';

final class AppBreakpoints {
  const AppBreakpoints._();

  static const double compactShortestSide = 560;
  static const double boardMaxWidth = 520;
  static const double dialogMaxWidth = 380;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide < compactShortestSide;
  }
}
