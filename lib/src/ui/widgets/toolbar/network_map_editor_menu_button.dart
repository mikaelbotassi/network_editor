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
          borderRadius: BorderRadius.circular(4),
          color: isActive ? colors.primary : Colors.white,
        ),
        child: Icon(TablerIcons.menu2, color: isActive ? colors.onPrimary : colors.primary),
      )
    );
  }
}
