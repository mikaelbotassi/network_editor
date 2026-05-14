import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class CropConfirmButton extends StatelessWidget {
  const CropConfirmButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(TablerIcons.crop, size: 18),
                SizedBox(width: 8),
                Text('Usar recorte'),
              ],
            ),
    );
  }
}
