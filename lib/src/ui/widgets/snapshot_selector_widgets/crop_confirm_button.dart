import 'package:flutter/material.dart';
import 'package:network_editor/src/ui/widgets/core/primary_button.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class CropConfirmButton extends StatelessWidget {
  const CropConfirmButton({
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      icon: TablerIcons.crop,
      onPressed: onPressed,
      enabled: enabled,
    );
  }
}
