import 'package:flutter/material.dart';

/// 3D icon displayed in a white circular badge.
///
/// The icon PNGs are AI-generated 3D renders (assets/icons/*.png). Their
/// backgrounds are baked white, so they are always shown inside this white
/// badge — backgrounds are never removed programmatically (user rule).
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
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.14),
      child: Image.asset(
        'assets/icons/$name.png',
        width: size,
        height: size,
        errorBuilder: (_, _, _) =>
            Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
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
