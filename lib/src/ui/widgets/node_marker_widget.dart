import 'package:network_editor/src/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NodeMarkerWidget extends StatelessWidget {
  final EditorNode node;
  final bool selected;
  final double iconSize;

  const NodeMarkerWidget({
    super.key,
    required this.node,
    required this.selected,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? Colors.orange : node.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: _buildMarkerContent(),
      ),
    );
  }

  Widget _buildMarkerContent() {
    if (node.svgPath != null && node.svgPath!.trim().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          node.svgPath!,
          width: iconSize,
          height: iconSize,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      );
    }

    return Icon(
      node.icon,
      color: Colors.white,
      size: iconSize,
    );
  }
}