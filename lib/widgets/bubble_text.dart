import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Chunky 3D golden bubble text: gold gradient letters, white outline,
/// dark-brown outer depth — the app's signature title style.
class BubbleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign textAlign;

  const BubbleText(
    this.text, {
    super.key,
    this.fontSize = 44,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFE08A), Color(0xFFFFC93C), KidsTheme.goldDark],
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
            // white outline (8 directions)
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
              Shadow(offset: o, color: Colors.white, blurRadius: 0),
            // dark-brown depth
            const Shadow(
                offset: Offset(0, 5),
                color: Color(0xFF8A5A00),
                blurRadius: 0),
            const Shadow(
                offset: Offset(0, 7),
                color: Colors.black26,
                blurRadius: 6),
          ],
        ),
      ),
    );
  }
}
