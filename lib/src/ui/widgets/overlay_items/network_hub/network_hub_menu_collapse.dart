import 'package:flutter/material.dart';
import 'package:network_editor/network_editor.dart';
import 'package:network_editor/src/ui/widgets/overlay_items/network_hub/layer_option.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

class NetworkHubMenuCollapse extends StatelessWidget {

  const NetworkHubMenuCollapse({
    super.key,
    required this.controller,
    required this.onClose
  });

  final NetworkHubOverlayController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Text(
                  'Camadas de rede',
                  style: TextStyle(fontWeight: FontWeight.w600,color: colors.primary),
                ),
              ),
              IconButton(
                tooltip: 'Fechar',
                onPressed: onClose,
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
                    statusMessage,
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
                  LayerOption(controller: controller, layer: layer),
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

  String get statusMessage {
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
