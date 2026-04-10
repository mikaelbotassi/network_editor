import 'package:electric_digital_sketch/electric_digital_sketch.dart';
import 'package:electric_digital_sketch/src/domain/entities/editor_mode_key.dart';
import 'package:flutter/material.dart';

class ToolbarActionItem {
  final IconData icon;
  final EditorModeKey mode;
  final String tooltip;

  const ToolbarActionItem({
    required this.icon,
    required this.mode,
    required this.tooltip,
  });
}

class NetworkMapToolbarItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const NetworkMapToolbarItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (colors, textTheme) = (Theme.of(context).colorScheme, Theme.of(context).textTheme);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          boxShadow: NetworkEditorShadows.overlayPanel,
          color: selected ? colors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          spacing: 8,
          children: [
            Text(label, style: textTheme.bodySmall!.apply(color: selected ? colors.onPrimaryContainer : colors.primary)),
            Icon(icon, color: selected ? colors.onPrimaryContainer : colors.primary, size: 14)
          ],
        ),
      ),
    );
  }
}