import 'package:network_editor/src/domain/domain.dart';
import 'package:flutter/material.dart';

class ConnectHintCard extends StatelessWidget {
  final EditorNode fromNode;
  final VoidCallback onCancel;

  const ConnectHintCard({
    super.key,
    required this.fromNode,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Origem selecionada: ${fromNode.label ?? fromNode.id}. Toque em outro nó para ligar a rede primária.',
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onCancel,
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}