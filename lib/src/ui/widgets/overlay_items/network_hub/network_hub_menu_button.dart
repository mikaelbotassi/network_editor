import 'package:flutter/material.dart';
import 'package:network_editor/network_editor.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

class NetworkHubMenuButton extends StatelessWidget {

  const NetworkHubMenuButton({
    super.key,
    required this.controller,
    required this.onPressed
  });

  final NetworkHubOverlayController controller;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: statusMessage,
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          onPressed: onPressed,
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
