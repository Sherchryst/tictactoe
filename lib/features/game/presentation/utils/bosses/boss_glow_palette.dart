import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';

final class BossGlowPalette {
  const BossGlowPalette({
    required this.core,
    required this.primary,
    required this.secondary,
    required this.edge,
    required this.particle,
  });

  final Color core;
  final Color primary;
  final Color secondary;
  final Color edge;
  final Color particle;

  static const guided = BossGlowPalette(
    core: AppPalette.ivoryText,
    primary: AppPalette.goldBright,
    secondary: AppPalette.gold,
    edge: AppPalette.emberRed,
    particle: AppPalette.goldBright,
  );

  static const radahn = BossGlowPalette(
    core: Color(0xffffe08a),
    primary: Color(0xffff7a3a),
    secondary: Color(0xffd83a21),
    edge: Color(0xff5f120b),
    particle: Color(0xffffb35d),
  );

  static const mohg = BossGlowPalette(
    core: Color(0xffff8f98),
    primary: Color(0xffff1f35),
    secondary: Color(0xffb00025),
    edge: Color(0xff430711),
    particle: Color(0xffff4a65),
  );

  static const malenia = BossGlowPalette(
    core: Color(0xfffff1bb),
    primary: Color(0xffffbd88),
    secondary: Color(0xffff7461),
    edge: Color(0xff721b14),
    particle: Color(0xffffd59a),
  );
}
