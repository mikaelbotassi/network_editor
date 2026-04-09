import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class NetworkMapEditorMenuButton extends StatelessWidget {

  final bool isActive;
  final VoidCallback onTap;

  const NetworkMapEditorMenuButton({super.key, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              spreadRadius: 3,
              offset: Offset.zero,
              color: colors.primary.withAlpha(50)
            )
          ],
          border: Border.all(color: isActive ? Colors.white : colors.primary),
          borderRadius: BorderRadius.circular(4),
          color: isActive ? colors.primary : Colors.white,
        ),
        child: Icon(TablerIcons.menu2, color: isActive ? colors.onPrimary : colors.primary, size: 14),
      )
    );
  }
}
