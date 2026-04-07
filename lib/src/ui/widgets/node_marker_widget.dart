import 'package:electric_digital_sketch/src/domain/domain.dart';
import 'package:flutter/material.dart';

class NodeMarkerWidget extends StatelessWidget {
  final EditorNode node;
  final bool selected;

  const NodeMarkerWidget({
    required this.node,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (node.type) {
      EditorNodeType.pole => Colors.brown,
      EditorNodeType.transformer => Colors.blue,
      EditorNodeType.switcher => Colors.purple,
      EditorNodeType.consumerUnit => Colors.green,
      EditorNodeType.generic => Colors.grey,
    };

    return Container(
      decoration: BoxDecoration(
        color: selected ? Colors.orange : color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        switch (node.type) {
          EditorNodeType.pole => Icons.power,
          EditorNodeType.transformer => Icons.electrical_services,
          EditorNodeType.switcher => Icons.toggle_on,
          EditorNodeType.consumerUnit => Icons.home,
          EditorNodeType.generic => Icons.location_on,
        },
        color: Colors.white,
        size: 18,
      ),
    );
  }
}