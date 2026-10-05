import 'package:flutter/material.dart';
import 'package:network_editor/network_editor.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

class LayerOption extends StatelessWidget {
  const LayerOption({
    super.key,
    required this.controller,
    required this.layer
  });

  final NetworkHubOverlayController controller;
  final hub.NetworkLayer layer;

  @override
  Widget build(BuildContext context) {
    final activeAtZoom = controller.currentZoom >= layer.minimumZoom;
    final colors = Theme.of(context).colorScheme;

    return CheckboxListTile(
      value: controller.isLayerVisible(layer),
      onChanged: (value) => controller.setLayerVisible(layer, value ?? false),
      dense: true,
      visualDensity: VisualDensity.compact,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      secondary: Icon(
        layer.icon,
        size: 18,
        color: activeAtZoom ? layer.mapColor : colors.outline,
      ),
      title: Text(
        layer.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: activeAtZoom ? null : colors.outline,
        ),
      ),
      subtitle: activeAtZoom
          ? null
          : Text(
        'Visível a partir do zoom ${layer.minimumZoom}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}