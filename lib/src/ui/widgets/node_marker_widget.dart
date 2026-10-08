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
          width: 38,
          height: 38,
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
        if (structuresCount > 1)
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

  Widget _buildMarkerContent(Color defaultColor) {
    final rawIcons = node.properties['grouped_icons'];
    final rawColors = node.properties['grouped_colors'];

    if (rawIcons is List && rawColors is List && rawIcons.length > 1) {
      final icons = rawIcons.cast<IconData>();
      final colors = rawColors.cast<Color>();
      return _buildMultiIconContent(icons, colors);
    }

    if (node.svgPath != null && node.svgPath!.trim().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: SvgPicture.asset(
          node.svgPath!,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            defaultColor,
            BlendMode.srcIn,
          ),
        ),
      );
    }

    return Icon(
      node.icon,
      color: defaultColor,
      size: iconSize,
    );
  }

  Widget _buildMultiIconContent(List<IconData> icons, List<Color> colors) {
    if (icons.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[0], size: 11, color: colors[0]),
          const SizedBox(width: 1),
          Icon(icons[1], size: 11, color: colors[1]),
        ],
      );
    }

    final displayIcons = icons.take(4).toList();
    final displayColors = colors.take(4).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(displayIcons[0], size: 9, color: displayColors[0]),
            if (displayIcons.length > 1) ...[
              const SizedBox(width: 1),
              Icon(displayIcons[1], size: 9, color: displayColors[1]),
            ],
          ],
        ),
        if (displayIcons.length > 2) ...[
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(displayIcons[2], size: 9, color: displayColors[2]),
              if (displayIcons.length > 3) ...[
                const SizedBox(width: 1),
                Icon(displayIcons[3], size: 9, color: displayColors[3]),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
