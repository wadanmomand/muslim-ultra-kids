import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Cute 3D-style crescent mascot companion (CustomPainter).
/// The real 3D mascot asset lands in Phase 4; this keeps Phase 2 playable.
class Companion extends StatelessWidget {
  final double size;
  final bool happy;

  const Companion({super.key, this.size = 96, this.happy = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CrescentPainter(happy: happy)),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  final bool happy;
  _CrescentPainter({required this.happy});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Golden crescent: big circle minus offset circle.
    final gold = Paint()..color = KidsTheme.gold;
    canvas.drawCircle(Offset(w * 0.45, w * 0.5), w * 0.38, gold);
    final cut = Paint()
      ..color = KidsTheme.skyBottom
      ..style = PaintingStyle.fill;
    // Match the card/sky behind; good enough for Phase 2 placeholder.
    canvas.drawCircle(Offset(w * 0.62, w * 0.38), w * 0.32, cut);

    // Face on the crescent.
    final eye = Paint()..color = KidsTheme.ink;
    canvas.drawCircle(Offset(w * 0.36, w * 0.46), w * 0.045, eye);
    final smile = Paint()
      ..color = KidsTheme.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    if (happy) {
      final rect = Rect.fromCenter(
        center: Offset(w * 0.38, w * 0.56),
        width: w * 0.16,
        height: w * 0.1,
      );
      canvas.drawArc(rect, 0.15 * 3.14, 0.7 * 3.14, false, smile);
    } else {
      final rect = Rect.fromCenter(
        center: Offset(w * 0.38, w * 0.62),
        width: w * 0.14,
        height: w * 0.09,
      );
      canvas.drawArc(rect, 1.15 * 3.14, 0.7 * 3.14, false, smile);
    }
    // Cheek blush.
    final blush = Paint()..color = const Color(0xFFFF9E9E).withValues(alpha: 0.7);
    canvas.drawCircle(Offset(w * 0.28, w * 0.56), w * 0.05, blush);
  }

  @override
  bool shouldRepaint(covariant _CrescentPainter old) =>
      old.happy != happy;
}

/// Speech bubble from the companion.
class CompanionBubble extends StatelessWidget {
  final String text;
  final bool happy;

  const CompanionBubble({super.key, required this.text, this.happy = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Companion(size: 72, happy: happy),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
