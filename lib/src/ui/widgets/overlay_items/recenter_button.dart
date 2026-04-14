import 'package:electric_digital_sketch/electric_digital_sketch.dart';
import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class RecenterButton extends StatelessWidget {

  final VoidCallback onTap;

  const RecenterButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.primary,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(4),
          boxShadow: NetworkEditorShadows.overlayPanel
        ),
        child: Icon(TablerIcons.compass, color: Colors.white, size: 32),
      ),
    );
  }
}
