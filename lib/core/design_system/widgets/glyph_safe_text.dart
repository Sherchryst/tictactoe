import 'package:flutter/material.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';

class GlyphSafeText extends StatelessWidget {
  const GlyphSafeText(
    this.text, {
    required this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fallbackFontFamily = AppPalette.serifFont,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String fallbackFontFamily;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: _spans()),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  List<InlineSpan> _spans() {
    return [
      for (final rune in text.runes)
        TextSpan(
          text: String.fromCharCode(rune),
          style: _fallbackRunes.contains(rune)
              ? style?.copyWith(fontFamily: fallbackFontFamily)
              : style,
        ),
    ];
  }

  static const _fallbackRunes = {0x2B};
}
