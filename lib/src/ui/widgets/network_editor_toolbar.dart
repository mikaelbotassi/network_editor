import 'package:electric_digital_sketch/src/domain/enums/network_edit_mode.dart';
import 'package:electric_digital_sketch/src/ui/viewmodels/network_editor_viewmodel.dart';
import 'package:flutter/material.dart';

class NetworkEditorToolbar extends StatelessWidget {
  final NetworkEditorViewmodel controller;

  const NetworkEditorToolbar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _tool(Icons.pan_tool_alt, NetworkEditMode.view, 'Visualizar'),
            _tool(Icons.add_location_alt, NetworkEditMode.addPole, 'Novo poste'),
            _tool(Icons.add_business, NetworkEditMode.addTransformer, 'Novo trafo'),
            _tool(Icons.timeline, NetworkEditMode.connectPrimary, 'Ligar rede'),
            _tool(Icons.open_with, NetworkEditMode.moveNode, 'Mover'),
            _tool(Icons.delete, NetworkEditMode.delete, 'Excluir'),
          ],
        ),
      ),
    );
  }

  Widget _tool(IconData icon, NetworkEditMode mode, String tooltip) {
    final selected = controller.mode == mode;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => controller.setMode(mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? Colors.blue.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? Colors.blue : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            icon,
            color: selected ? Colors.blue : Colors.black87,
          ),
        ),
      ),
    );
  }
}