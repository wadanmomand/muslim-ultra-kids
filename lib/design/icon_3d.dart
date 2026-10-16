import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Vector 3D icons — drawn in code with real gradients, highlights and
/// depth. Replaces the old flat PNG icon set (which had baked white
/// backgrounds and could never look 3D). Every redesigned screen uses
/// these; no image assets needed.
enum Icon3D {
  lock,
  star,
  speaker,
  play,
  check,
  close,
  download,
  crown,
  refresh,
  mic,
  hourglass,
}

class Icon3DWidget extends StatelessWidget {
  final Icon3D icon;
  final double size;

  const Icon3DWidget(this.icon, {super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _Icon3DPainter(icon)),
    );
  }
}

class _Icon3DPainter extends CustomPainter {
  final Icon3D icon;
  const _Icon3DPainter(this.icon);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100; // work in a 100x100 box
    canvas.save();
    canvas.scale(s);
    switch (icon) {
      case Icon3D.lock:
        _lock(canvas);
      case Icon3D.star:
        _star(canvas, 50, 50, 44);
      case Icon3D.speaker:
        _speaker(canvas);
      case Icon3D.play:
        _play(canvas);
      case Icon3D.check:
        _check(canvas);
      case Icon3D.close:
        _close(canvas);
      case Icon3D.download:
        _download(canvas);
      case Icon3D.crown:
        _crown(canvas);
      case Icon3D.refresh:
        _refresh(canvas);
      case Icon3D.mic:
        _mic(canvas);
      case Icon3D.hourglass:
        _hourglass(canvas);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  // ---------- helpers ----------

  /// Vertical 3D gradient paint.
  Paint _grad(List<Color> colors, {double y0 = 0, double y1 = 100}) {
    return Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, y0, 100, y1 - y0));
  }

  /// Glossy white top highlight.
  void _gloss(Canvas canvas, Rect r, {double opacity = 0.55}) {
    final p = Paint()..color = Colors.white.withValues(alpha: opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(r.left + r.width * 0.12, r.top + r.height * 0.06,
            r.width * 0.76, r.height * 0.30),
        const Radius.circular(20),
      ),
      p,
    );
  }

  void _circle3d(Canvas canvas, Offset c, double r, List<Color> colors,
      Color edge) {
    canvas.drawCircle(
        c + const Offset(0, 4), r, Paint()..color = Colors.black26);
    canvas.drawCircle(c, r, _grad(colors));
    canvas.drawCircle(
        c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = edge);
    _gloss(canvas, Rect.fromCircle(center: c, radius: r), opacity: 0.35);
  }

  // ---------- icons ----------

  void _star(Canvas canvas, double cx, double cy, double r) {
    final pts = <Offset>[];
    for (var i = 0; i < 10; i++) {
      final ang = -math.pi / 2 + i * math.pi / 5;
      final rr = i.isEven ? r : r * 0.45;
      pts.add(Offset(cx + rr * math.cos(ang), cy + rr * math.sin(ang)));
    }
    final path = Path()..addPolygon(pts, true);
    canvas.drawPath(
        path.shift(const Offset(0, 4)), Paint()..color = Colors.black26);
    canvas.drawPath(path, _grad(const [Color(0xFFFFE08A), Color(0xFFFFC93C), Color(0xFFE8A400)]));
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFB87A00));
    // top facet highlight
    final hp = Path()
      ..moveTo(cx - r * 0.28, cy - r * 0.62)
      ..lineTo(cx, cy - r * 0.18)
      ..lineTo(cx + r * 0.28, cy - r * 0.62)
      ..close();
    canvas.drawPath(hp, Paint()..color = Colors.white.withValues(alpha: 0.5));
  }

  void _lock(Canvas canvas) {
    // shackle
    final shackle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE8EEF5), Color(0xFF9AA7B8)],
      ).createShader(const Rect.fromLTWH(0, 8, 100, 50));
    canvas.drawArc(const Rect.fromLTWH(26, 10, 48, 52), math.pi, 0, false, shackle);
    // body
    final body = RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, 42, 60, 50), const Radius.circular(14));
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(20, 46, 60, 50),
            const Radius.circular(14)),
        Paint()..color = Colors.black26);
    canvas.drawRRect(
        body,
        _grad(const [Color(0xFFB9C6D6), Color(0xFF7E8FA3), Color(0xFF5A6B80)]));
    canvas.drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF3E4C5E));
    _gloss(canvas, const Rect.fromLTWH(20, 42, 60, 50));
    // keyhole
    canvas.drawCircle(const Offset(50, 64), 7, Paint()..color = const Color(0xFF2E3A48));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(47, 68, 6, 12), const Radius.circular(3)),
        Paint()..color = const Color(0xFF2E3A48));
  }

  void _speaker(Canvas canvas) {
    final box = RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 8, 84, 84), const Radius.circular(24));
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 84),
            const Radius.circular(24)),
        Paint()..color = Colors.black26);
    canvas.drawRRect(
        box, _grad(const [Color(0xFF5FE3D6), Color(0xFF1FAE9F), Color(0xFF0E7C72)]));
    canvas.drawRRect(
        box,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = Colors.white.withValues(alpha: 0.85));
    _gloss(canvas, const Rect.fromLTWH(8, 8, 84, 84), opacity: 0.3);
    // cone
    final cone = Path()
      ..moveTo(30, 44)
      ..lineTo(44, 44)
      ..lineTo(56, 32)
      ..lineTo(56, 68)
      ..lineTo(44, 56)
      ..lineTo(30, 56)
      ..close();
    canvas.drawPath(cone, Paint()..color = Colors.white);
    // waves
    for (final r in [16.0, 28.0]) {
      canvas.drawArc(Rect.fromCircle(center: const Offset(58, 50), radius: r),
          -0.9, 1.8, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round..color = Colors.white);
    }
  }

  void _play(Canvas canvas) {
    _circle3d(canvas, const Offset(50, 50), 44,
        const [Color(0xFFFFD964), Color(0xFFF5A623), Color(0xFFD88A00)],
        const Color(0xFF9A6200));
    final tri = Path()
      ..moveTo(40, 30)
      ..lineTo(72, 50)
      ..lineTo(40, 70)
      ..close();
    canvas.drawPath(tri.shift(const Offset(0, 3)),
        Paint()..color = Colors.black26);
    canvas.drawPath(tri, Paint()..color = Colors.white);
  }

  void _check(Canvas canvas) {
    _circle3d(canvas, const Offset(50, 50), 44,
        const [Color(0xFF7BE3A0), Color(0xFF2ECC71), Color(0xFF1A9E50)],
        const Color(0xFF0F7A3C));
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;
    canvas.drawPath(
        Path()
          ..moveTo(32, 52)
          ..lineTo(46, 66)
          ..lineTo(70, 36),
        p);
  }

  void _close(Canvas canvas) {
    _circle3d(canvas, const Offset(50, 50), 44,
        const [Color(0xFFFF8A80), Color(0xFFF44336), Color(0xFFC62828)],
        const Color(0xFF8E1B1B));
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;
    canvas.drawLine(const Offset(36, 36), const Offset(64, 64), p);
    canvas.drawLine(const Offset(64, 36), const Offset(36, 64), p);
  }

  void _download(Canvas canvas) {
    _circle3d(canvas, const Offset(50, 50), 44,
        const [Color(0xFF7FB5F5), Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        const Color(0xFF173EAB));
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;
    canvas.drawLine(const Offset(50, 30), const Offset(50, 62), p);
    canvas.drawPath(
        Path()
          ..moveTo(34, 50)
          ..lineTo(50, 66)
          ..lineTo(66, 50),
        p);
    canvas.drawLine(const Offset(34, 74), const Offset(66, 74), p);
  }

  void _crown(Canvas canvas) {
    final crown = Path()
      ..moveTo(18, 72)
      ..lineTo(14, 34)
      ..lineTo(32, 50)
      ..lineTo(50, 24)
      ..lineTo(68, 50)
      ..lineTo(86, 34)
      ..lineTo(82, 72)
      ..close();
    canvas.drawPath(crown.shift(const Offset(0, 4)),
        Paint()..color = Colors.black26);
    canvas.drawPath(
        crown,
        _grad(const [Color(0xFFFFE08A), Color(0xFFFFC93C), Color(0xFFE8A400)],
            y0: 24, y1: 72));
    canvas.drawPath(
        crown,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFB87A00));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(18, 72, 64, 10), const Radius.circular(5)),
        _grad(const [Color(0xFFFFC93C), Color(0xFFE8A400)]));
    for (final dx in [32.0, 50.0, 68.0]) {
      canvas.drawCircle(Offset(dx, 44), 5,
          Paint()..color = const Color(0xFFE53935));
    }
  }

  void _refresh(Canvas canvas) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF5FE3D6), Color(0xFF0E7C72)],
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100));
    canvas.drawArc(const Rect.fromLTWH(18, 18, 64, 64), -0.4, 3.6, false, p);
    canvas.drawArc(const Rect.fromLTWH(18, 18, 64, 64), math.pi - 0.4, 3.6,
        false, p);
    // arrowheads
    for (final a in [-0.4, math.pi - 0.4]) {
      final tip = Offset(50 + 32 * math.cos(a), 50 + 32 * math.sin(a));
      final p1 = Offset(50 + 20 * math.cos(a + 0.5), 50 + 20 * math.sin(a + 0.5));
      final p2 = Offset(50 + 20 * math.cos(a - 0.5), 50 + 20 * math.sin(a - 0.5));
      canvas.drawPath(Path()..moveTo(tip.dx, tip.dy)..lineTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..close(),
          Paint()..color = const Color(0xFF0E7C72));
    }
  }

  void _mic(Canvas canvas) {
    // head
    final head = RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 10, 36, 52), const Radius.circular(18));
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(32, 14, 36, 52),
            const Radius.circular(18)),
        Paint()..color = Colors.black26);
    canvas.drawRRect(
        head,
        _grad(const [Color(0xFFB388EB), Color(0xFF7B4FD6), Color(0xFF5A32A8)],
            y0: 10, y1: 62));
    _gloss(canvas, const Rect.fromLTWH(32, 10, 36, 52), opacity: 0.35);
    // grille lines
    final gp = Paint()..color = Colors.white.withValues(alpha: 0.5)..strokeWidth = 3;
    for (final yy in [24.0, 34.0, 44.0]) {
      canvas.drawLine(Offset(38, yy), Offset(62, yy), gp);
    }
    // stand arc + stem + base
    final sp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF5A32A8);
    canvas.drawArc(const Rect.fromLTWH(28, 44, 44, 40), 0.3, math.pi - 0.6, false, sp);
    canvas.drawLine(const Offset(50, 82), const Offset(50, 90), sp);
    canvas.drawLine(const Offset(36, 92), const Offset(64, 92), sp);
  }

  void _hourglass(Canvas canvas) {
    // glass
    final glass = Path()
      ..moveTo(30, 12)
      ..lineTo(70, 12)
      ..lineTo(56, 44)
      ..lineTo(70, 76)
      ..lineTo(30, 76)
      ..lineTo(44, 44)
      ..close();
    canvas.drawPath(glass.shift(const Offset(0, 4)),
        Paint()..color = Colors.black26);
    canvas.drawPath(
        glass,
        _grad(const [Color(0xFFDFF3FF), Color(0xFFBFE3F5), Color(0xFF9CC8E0)],
            y0: 12, y1: 76));
    // sand
    canvas.drawPath(
        Path()
          ..moveTo(38, 76)
          ..lineTo(62, 76)
          ..lineTo(54, 56)
          ..lineTo(46, 56)
          ..close(),
        Paint()..color = const Color(0xFFF5A623));
    canvas.drawPath(
        Path()
          ..moveTo(46, 30)
          ..lineTo(54, 30)
          ..lineTo(50, 44)
          ..close(),
        Paint()..color = const Color(0xFFF5A623));
    // caps
    final capP = _grad(const [Color(0xFF8A6D3B), Color(0xFF5C3D1E)], y0: 4, y1: 16);
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(24, 4, 52, 12),
            const Radius.circular(6)),
        capP);
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(24, 84, 52, 12),
            const Radius.circular(6)),
        capP);
  }
}
