import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:network_editor/src/domain/entities/editor_node.dart';
import 'package:network_editor/src/ui/styles/network_hub/network_hub_feature_style.dart';
import 'package:network_editor/src/ui/styles/network_hub/network_hub_layer_style.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

/// Representation of an electrical equipment coupled to a central node.
class CoupledSatelliteItem {
  const CoupledSatelliteItem({
    required this.icon,
    required this.color,
    this.title,
    this.subtitle,
    this.feature,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String? title;
  final String? subtitle;
  final hub.NetworkFeature? feature;
  final VoidCallback? onTap;
}

/// Representation of the central support node (e.g. pole or primary structure).
class CoupledCenterNode {
  const CoupledCenterNode({
    this.isPole = true,
    this.color = const Color(0xFF384654),
    this.icon,
    this.title,
    this.feature,
    this.onTap,
  });

  final bool isPole;
  final Color color;
  final IconData? icon;
  final String? title;
  final hub.NetworkFeature? feature;
  final VoidCallback? onTap;
}

/// Widget that displays a node with its coupled equipment arranged in a
/// circular orbit around the central support node.
///
/// Closely models electrical distribution schematics where equipment
/// (transformers, switches, regulators, capacitors) are mounted on a pole.
class CoupledNodeMarkerWidget extends StatelessWidget {
  const CoupledNodeMarkerWidget({
    super.key,
    required this.center,
    required this.satellites,
    this.orbitColor = const Color(0xFF384654),
    this.orbitStrokeWidth = 2,
    this.centerSize = 32.0,
    this.satelliteSize = 24.0,
    this.selected = false,
  });

  final CoupledCenterNode center;
  final List<CoupledSatelliteItem> satellites;
  final Color orbitColor;
  final double orbitStrokeWidth;
  final double centerSize;
  final double satelliteSize;
  final bool selected;

  /// Creates a [CoupledNodeMarkerWidget] from a list of [hub.NetworkFeature]s
  /// grouped at the same point (pole/node).
  factory CoupledNodeMarkerWidget.fromFeatures({
    Key? key,
    required List<hub.NetworkFeature> features,
    ValueChanged<hub.NetworkFeature>? onFeatureTap,
    bool selected = false,
  }) {
    if (features.isEmpty) {
      return CoupledNodeMarkerWidget(
        key: key,
        center: const CoupledCenterNode(),
        satellites: const [],
        selected: selected,
      );
    }

    // Identify if a pole feature exists in the group
    final pole = features.cast<hub.NetworkFeature?>().firstWhere(
      (f) => f?.layer == hub.NetworkLayer.poste,
      orElse: () => null,
    );

    final CoupledCenterNode centerNode;
    final List<hub.NetworkFeature> satelliteFeatures;

    if (pole != null) {
      centerNode = CoupledCenterNode(
        isPole: true,
        icon: pole.icon,
        color: selected ? Colors.orange : pole.layer.mapColor,
        title: pole.title ?? '${pole.layer.label} #${pole.id}',
        feature: pole,
        onTap: () => onFeatureTap?.call(pole),
      );
      // All other features in the group are satellites
      satelliteFeatures = features
          .where((f) => f != pole)
          .toList(growable: false);
    } else if (features.length == 1) {
      final single = features.first;
      centerNode = CoupledCenterNode(
        isPole: false,
        color: selected ? Colors.orange : single.layer.mapColor,
        icon: single.icon,
        title: single.title ?? '${single.layer.label} #${single.id}',
        feature: single,
        onTap: () => onFeatureTap?.call(single),
      );
      satelliteFeatures = const [];
    } else {
      // Group without explicit pole feature: the center represents the support node
      final primary = features.first;
      centerNode = CoupledCenterNode(
        isPole: true,
        color: selected ? Colors.orange : const Color(0xFF384654),
        title: primary.title ?? 'Ponto #${primary.id}',
        feature: primary,
        onTap: () => onFeatureTap?.call(primary),
      );
      satelliteFeatures = features;
    }

    final satellites = satelliteFeatures
        .map((f) {
          return CoupledSatelliteItem(
            icon: f.icon,
            color: f.layer.mapColor,
            title: f.title ?? '${f.layer.label} #${f.id}',
            subtitle: f.subtitle,
            feature: f,
            onTap: () => onFeatureTap?.call(f),
          );
        })
        .toList(growable: false);

    return CoupledNodeMarkerWidget(
      key: key,
      center: centerNode,
      satellites: satellites,
      selected: selected,
    );
  }

  /// Creates a [CoupledNodeMarkerWidget] from an [EditorNode].
  factory CoupledNodeMarkerWidget.fromEditorNode({
    Key? key,
    required EditorNode node,
    bool selected = false,
    ValueChanged<Map<String, dynamic>>? onStructureTap,
    VoidCallback? onNodeTap,
  }) {
    final structures =
        (node.properties['structures'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const [];

    final rawIcons = node.properties['grouped_icons'];
    final rawColors = node.properties['grouped_colors'];
    final hasPole = node.properties['has_pole'] == true;

    final centerNode = CoupledCenterNode(
      isPole: hasPole,
      color: selected ? Colors.orange : node.color,
      icon: node.icon,
      title: node.label ?? 'Nó #${node.id}',
      onTap: onNodeTap,
    );

    if (structures.isEmpty && (rawIcons is! List || rawIcons.length <= 1)) {
      return CoupledNodeMarkerWidget(
        key: key,
        center: centerNode,
        satellites: const [],
        selected: selected,
      );
    }

    final satellites = <CoupledSatelliteItem>[];

    if (structures.isNotEmpty) {
      for (final struct in structures) {
        final title = struct['title'] ?? struct['layer'] ?? 'Estrutura';
        final layerCode = struct['layer_code']?.toString();
        final layer = hub.NetworkLayer.values
            .cast<hub.NetworkLayer?>()
            .firstWhere((l) => '${l?.code}' == layerCode, orElse: () => null);
        final color = layer?.mapColor ?? node.color;
        final icon = layer?.icon ?? node.icon;

        satellites.add(
          CoupledSatelliteItem(
            icon: icon,
            color: color,
            title: '$title',
            subtitle: struct['subtitle']?.toString(),
            onTap: onStructureTap != null ? () => onStructureTap(struct) : null,
          ),
        );
      }
    } else if (rawIcons is List && rawColors is List) {
      final icons = rawIcons.cast<IconData>();
      final colors = rawColors.cast<Color>();
      for (var i = 0; i < icons.length; i++) {
        satellites.add(
          CoupledSatelliteItem(
            icon: icons[i],
            color: i < colors.length ? colors[i] : node.color,
          ),
        );
      }
    }

    return CoupledNodeMarkerWidget(
      key: key,
      center: centerNode,
      satellites: satellites,
      selected: selected,
    );
  }

  /// Calculates the orbit radius based on the number of satellites so that
  /// all badges have sufficient clearance and do not collide.
  static double calculateOrbitRadius(int satelliteCount) {
    const baseOrbitRadius = 35.0;
    if (satelliteCount <= 8) {
      return baseOrbitRadius;
    }
    final requiredRadius = (satelliteCount * 25.5) / (2 * math.pi);
    return math.max(baseOrbitRadius, requiredRadius);
  }

  /// Calculates the bounding box size (width and height) needed to contain
  /// the center node, orbit ring, satellites, and shadows.
  static double calculateMarkerSize(int satelliteCount) {
    if (satelliteCount == 0) return 38.0;
    final orbitRadius = calculateOrbitRadius(satelliteCount);
    const satRadius = 12.0;
    const margin = 5.0;
    return ((orbitRadius + satRadius + margin) * 2).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (satellites.isEmpty) {
      return Center(child: _buildCenterWidget(centerSize));
    }

    final totalSize = calculateMarkerSize(satellites.length);
    final orbitRadius = calculateOrbitRadius(satellites.length);
    final cx = totalSize / 2;
    final cy = totalSize / 2;
    final count = satellites.length;

    final effectiveOrbitColor = selected ? Colors.orange : orbitColor;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Orbit track connecting the satellites in a circle
          Positioned.fill(
            child: CustomPaint(
              painter: OrbitPainter(
                radius: orbitRadius,
                color: effectiveOrbitColor,
                strokeWidth: orbitStrokeWidth,
              ),
            ),
          ),

          // 2. Center support node (concentric circles for pole)
          Positioned(
            left: cx - (centerSize / 2),
            top: cy - (centerSize / 2),
            child: _buildCenterWidget(centerSize),
          ),

          // 3. Satellite badges distributed evenly along the orbit ring
          for (var i = 0; i < count; i++)
            _buildSatellitePositioned(
              index: i,
              totalCount: count,
              cx: cx,
              cy: cy,
              orbitRadius: orbitRadius,
            ),
        ],
      ),
    );
  }

  Widget _buildCenterWidget(double size) {
    final strokeWidth = size * 0.11;
    final innerSize = size * 0.46;
    final color = center.color;

    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: strokeWidth),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Center(
        child: center.isPole
            ? Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: strokeWidth),
                ),
              )
            : Icon(
                center.icon ?? Icons.circle,
                color: color,
                size: size * 0.55,
              ),
      ),
    );

    if (center.onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: center.onTap,
        child: content,
      );
    }

    if (center.title != null && center.title!.isNotEmpty) {
      content = Tooltip(message: center.title!, child: content);
    }

    return content;
  }

  Widget _buildSatellitePositioned({
    required int index,
    required int totalCount,
    required double cx,
    required double cy,
    required double orbitRadius,
  }) {
    final item = satellites[index];
    // Start from top (12 o'clock, -pi/2) and rotate clockwise
    final angle = -math.pi / 2 + (index * 2 * math.pi / totalCount);
    final x = cx + orbitRadius * math.cos(angle);
    final y = cy + orbitRadius * math.sin(angle);

    final iconSize = _getSatelliteIconSize(item);

    Widget badge = Container(
      width: satelliteSize,
      height: satelliteSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: item.color, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Center(
        child: Icon(item.icon, color: item.color, size: iconSize),
      ),
    );

    if (item.onTap != null) {
      badge = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: item.onTap,
        child: badge,
      );
    }

    if (item.title != null && item.title!.isNotEmpty) {
      badge = Tooltip(message: item.title!, child: badge);
    }

    return Positioned(
      left: x - (satelliteSize / 2),
      top: y - (satelliteSize / 2),
      child: badge,
    );
  }

  double _getSatelliteIconSize(CoupledSatelliteItem item) {
    if (item.feature != null) {
      final layer = item.feature!.layer;
      final ratio = switch (layer) {
        hub.NetworkLayer.capacitora => 0.65,
        hub.NetworkLayer.reguladora => 0.65,
        _ => 0.56,
      };
      return satelliteSize * ratio;
    }
    return satelliteSize * 0.58;
  }
}

class OrbitPainter extends CustomPainter {
  const OrbitPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
  });

  final double radius;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant OrbitPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
