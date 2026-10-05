import 'package:flutter/material.dart';
import 'package:network_editor/src/ui/viewmodels/network_hub_overlay_controller.dart';
import 'package:network_editor/src/ui/widgets/overlay_items/network_hub/network_hub_menu_button.dart';
import 'package:network_editor/src/ui/widgets/overlay_items/network_hub/network_hub_menu_collapse.dart';

class NetworkHubLayerControl extends StatefulWidget {
  const NetworkHubLayerControl({super.key, required this.controller});

  final NetworkHubOverlayController controller;

  @override
  State<NetworkHubLayerControl> createState() => _NetworkHubLayerControlState();
}

class _NetworkHubLayerControlState extends State<NetworkHubLayerControl> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.padding.vertical - 112;

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: _expanded ? 228 : 48,
        constraints: BoxConstraints(
          maxHeight: availableHeight.clamp(160, 430).toDouble(),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: _expanded ? NetworkHubMenuCollapse(
          controller: widget.controller,
          onClose:() => setState(() => _expanded = false)
        ) : NetworkHubMenuButton(
          controller: widget.controller,
          onPressed: () => setState(() => _expanded = true),
        ),
      ),
    );
  }
}
