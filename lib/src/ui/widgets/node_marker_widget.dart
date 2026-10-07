import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:network_editor/src/domain/domain.dart';

class NodeMarkerWidget extends StatelessWidget {
  final EditorNode node;
  final bool selected;
  final double iconSize;

  const NodeMarkerWidget({
    super.key,
    required this.node,
    this.selected = false,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = selected ? Colors.orange : node.color;
    final structuresCount = _getStructuresCount(node);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: mainColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(0, 1.5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _buildMarkerContent(mainColor),
            ),
          ),
        ),
        if (structuresCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                '$structuresCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  int _getStructuresCount(EditorNode node) {
    final structs = node.properties['structures'] ?? node.properties['estruturas'];
    if (structs is List) return structs.length;
    return 0;
  }

  Widget _buildMarkerContent(Color color) {
    if (node.svgPath != null && node.svgPath!.trim().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: SvgPicture.asset(
          node.svgPath!,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            color,
            BlendMode.srcIn,
          ),
        ),
      );
    }

    return Icon(
      node.icon,
      color: color,
      size: iconSize,
    );
  }
}
