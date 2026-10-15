import 'package:flutter/material.dart';

/// 3D icon displayed in a glossy white medallion.
///
/// The icon PNGs are AI-generated 3D renders (assets/icons/*.png) with baked
/// white backgrounds, so they are always shown inside this medallion — the
/// white badge blends with the baked background, and the glossy gradient +
/// highlight ring gives the 3D coin feel. Backgrounds are never removed
/// programmatically (user rule).
class KidsIcon extends StatelessWidget {
  final String name;
  final double size;

  const KidsIcon(this.name, {super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFE9EEF5)],
        ),
        border: Border.all(color: Colors.white, width: size * 0.06),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: size * 0.12,
            offset: Offset(0, size * 0.06),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: size * 0.06,
            offset: Offset(0, -size * 0.03),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/$name.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
        ),
      ),
    );
  }
}

/// Icon + label row, replacing emoji-prefixed strings.
class KidsIconLabel extends StatelessWidget {
  final String icon;
  final String label;
  final double iconSize;
  final TextStyle? style;

  const KidsIconLabel(this.icon, this.label,
      {super.key, this.iconSize = 24, this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        KidsIcon(icon, size: iconSize),
        const SizedBox(width: 8),
        Flexible(child: Text(label, style: style)),
      ],
    );
  }
}
