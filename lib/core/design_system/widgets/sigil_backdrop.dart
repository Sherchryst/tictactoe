import 'package:flutter/material.dart';

import 'package:tictactoe/core/design_system/tokens/app_assets.dart';

class SigilBackdrop extends StatelessWidget {
  const SigilBackdrop({
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    super.key,
  });

  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.sigil,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      excludeFromSemantics: true,
    );
  }
}
