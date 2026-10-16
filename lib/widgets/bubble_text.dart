import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Chunky 3D bubble text: gradient letters, outline, outer depth —
/// the app's signature title style. Defaults to the golden title look;
/// pass [gradientColors], [outlineColor] and [depthColor] for variants
/// (e.g. a white pop header over art backgrounds).
class BubbleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign textAlign;
  final List<Color> gradientColors;
  final Color outlineColor;
  final Color depthColor;

  const BubbleText(
    this.text, {
    super.key,
    this.fontSize = 44,
    this.textAlign = TextAlign.center,
    this.gradientColors = const [
      Color(0xFFFFE08A),
      Color(0xFFFFC93C),
      KidsTheme.goldDark
    ],
    this.outlineColor = Colors.white,
    this.depthColor = const Color(0xFF8A5A00),
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1.05,
          shadows: [
            // outline (8 directions)
            for (final o in [
              const Offset(-2.5, 0),
              const Offset(2.5, 0),
              const Offset(0, -2.5),
              const Offset(0, 2.5),
              const Offset(-2.5, -2.5),
              const Offset(2.5, -2.5),
              const Offset(-2.5, 2.5),
              const Offset(2.5, 2.5),
            ])
              Shadow(offset: o, color: outlineColor, blurRadius: 0),
            // depth: true 3D extrusion — stacked solid layers stepping down
            for (var i = 1; i <= 8; i++)
              Shadow(
                  offset: Offset(0, 2.5 + i.toDouble()),
                  color: depthColor,
                  blurRadius: 0),
            const Shadow(
                offset: Offset(0, 13), color: Colors.black26, blurRadius: 6),
          ],
        ),
      ),
    );
  }
}
