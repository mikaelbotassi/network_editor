import 'package:flutter/material.dart';

class Alert extends StatelessWidget {
  const Alert({
    required this.color,
    required this.text,
    this.icon,
    super.key
  });

  final Color color;
  final IconData? icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final lightColor = Color.alphaBlend(
      Colors.white.withValues(alpha: 0.6),
      color
    );
    final darkColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.5),
      color
    );
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: lightColor,
        border: Border.all(color: darkColor)
      ),
      child: Row(
        spacing: 12,
        children: [
          Icon(icon, color: darkColor),
          Expanded(child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(color: darkColor)
          ))
        ],
      ),
    );
  }
}
