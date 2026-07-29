import 'package:flutter/material.dart';
import 'package:network_editor/src/ui/styles/network_editor_shadows.dart';
import 'package:network_editor/src/ui/styles/network_hub_layer_style.dart';
import 'package:network_editor/src/ui/viewmodels/network_hub_overlay_controller.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

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
      color: colors.surface,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: _expanded ? 228 : 48,
        constraints: BoxConstraints(
          maxHeight: availableHeight.clamp(160, 430).toDouble(),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(4),
          boxShadow: NetworkEditorShadows.overlayPanel,
        ),
        child: _expanded ? _buildExpanded(context) : _buildCollapsed(context),
      ),
    );
  }

  Widget _buildCollapsed(BuildContext context) {
    final controller = widget.controller;
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: _statusMessage(controller),
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          onPressed: () => setState(() => _expanded = true),
          icon: controller.loading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  controller.error == null
                      ? Icons.layers_outlined
                      : Icons.layers_clear_outlined,
                  color: controller.error == null
                      ? colors.primary
                      : colors.error,
                ),
        ),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    final controller = widget.controller;
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 48,
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.layers_outlined, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Camadas de rede',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: 'Fechar',
                onPressed: () => setState(() => _expanded = false),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (controller.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 18, color: colors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage(controller),
                    style: TextStyle(color: colors.error, fontSize: 12),
                  ),
                ),
                IconButton(
                  tooltip: 'Tentar novamente',
                  visualDensity: VisualDensity.compact,
                  onPressed: controller.loading ? null : controller.refresh,
                  icon: const Icon(Icons.refresh, size: 20),
                ),
              ],
            ),
          ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final layer in hub.NetworkLayer.values)
                  _LayerOption(controller: controller, layer: layer),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              if (controller.loading)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              Expanded(
                child: Text(
                  '${controller.visibleFeatureCount} estruturas',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                'z${controller.currentZoom.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _statusMessage(NetworkHubOverlayController controller) {
    if (controller.error is hub.NetworkHubUnavailableException ||
        controller.hubAvailable == false) {
      return 'SMRE Hub indisponível';
    }
    if (controller.error is hub.NetworkHubPermissionException) {
      return 'Acesso ao SMRE Hub negado';
    }
    if (controller.error case final hub.NetworkHubException error) {
      return error.message;
    }
    if (controller.error case final error?) return error.toString();
    if (controller.loading) return 'Carregando estruturas';
    return 'Camadas de rede';
  }
}

class _LayerOption extends StatelessWidget {
  const _LayerOption({required this.controller, required this.layer});

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
