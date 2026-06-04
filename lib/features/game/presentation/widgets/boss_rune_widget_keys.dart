import 'package:flutter/widgets.dart';

enum BossRuneWidgetKey { introRuneShine, defeatDeadOpacity }

abstract final class BossRuneWidgetKeys {
  static const introRuneShine = ValueKey(BossRuneWidgetKey.introRuneShine);
  static const defeatDeadOpacity = ValueKey(
    BossRuneWidgetKey.defeatDeadOpacity,
  );
}
