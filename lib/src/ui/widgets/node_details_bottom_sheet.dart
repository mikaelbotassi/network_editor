import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:network_editor/src/domain/entities/editor_node.dart';
import 'package:network_editor/src/ui/styles/network_hub_layer_style.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

class NodeDetailsBottomSheet extends StatelessWidget {
  const NodeDetailsBottomSheet({
    super.key,
    this.node,
    this.feature,
  }) : assert(node != null || feature != null, 'node ou feature deve ser fornecido');

  final EditorNode? node;
  final hub.NetworkFeature? feature;

  static Future<void> show(
    BuildContext context, {
    required EditorNode node,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NodeDetailsBottomSheet(node: node),
    );
  }

  static Future<void> showFeatureDetails(
    BuildContext context, {
    required hub.NetworkFeature feature,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NodeDetailsBottomSheet(feature: feature),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final title = _getTitle();
    final subtitle = _getSubtitle();
    final mainColor = _getColor(colors);
    final iconData = _getIconData();
    final svgPath = node?.svgPath;
    final properties = _getProperties();
    final structures = _getStructures();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: mainColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withAlpha(80),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: svgPath != null && svgPath.trim().isNotEmpty
                            ? SvgPicture.asset(
                                svgPath,
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  mainColor,
                                  BlendMode.srcIn,
                                ),
                              )
                            : Icon(
                                iconData,
                                color: mainColor,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Body Content (Scrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status & Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (node != null) ...[
                          _BadgeChip(
                            label: node!.isNew ? 'Novo' : 'Existente',
                            icon: node!.isNew ? Icons.add_circle_outline : Icons.check_circle_outline,
                            color: node!.isNew ? Colors.green : Colors.blue,
                          ),
                          if (node!.groupId != null)
                            _BadgeChip(
                              label: 'Grupo: ${node!.groupId}',
                              icon: Icons.grid_view_rounded,
                              color: colors.secondary,
                            ),
                        ],
                        if (feature != null)
                          _BadgeChip(
                            label: feature!.layer.label,
                            icon: feature!.layer.icon,
                            color: feature!.layer.mapColor,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Coordinates Section
                    _buildSectionHeader(
                      context,
                      title: 'Localização',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 8),
                    _buildCoordinatesCard(context),
                    const SizedBox(height: 16),

                    // Structures Section
                    if (structures.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        title: 'Estruturas Contidas (${structures.length})',
                        icon: Icons.account_tree_outlined,
                      ),
                      const SizedBox(height: 8),
                      ...structures.map((s) => _buildStructureCard(context, s)),
                      const SizedBox(height: 16),
                    ],

                    // Properties Section
                    if (properties.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        title: 'Detalhes da Estrutura',
                        icon: Icons.info_outline,
                      ),
                      const SizedBox(height: 8),
                      _buildPropertiesCard(context, properties),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    if (node != null) {
      if (node!.label != null && node!.label!.isNotEmpty) {
        return node!.label!;
      }
      return 'Nó ${node!.id}';
    }
    if (feature != null) {
      return feature!.title ?? '${feature!.layer.label} #${feature!.id}';
    }
    return 'Estrutura';
  }

  String? _getSubtitle() {
    if (node != null) {
      return '${node!.latitude.toStringAsFixed(6)}, ${node!.longitude.toStringAsFixed(6)}';
    }
    if (feature != null) {
      return feature!.subtitle ?? 'ID: ${feature!.id}';
    }
    return null;
  }

  Color _getColor(ColorScheme colors) {
    if (node != null) return node!.color;
    if (feature != null) return feature!.layer.mapColor;
    return colors.primary;
  }

  IconData _getIconData() {
    if (node != null) return node!.icon;
    if (feature != null) return feature!.layer.icon;
    return Icons.place;
  }

  Map<String, dynamic> _getProperties() {
    final rawProps = node?.properties ?? feature?.properties ?? {};
    final map = <String, dynamic>{};
    for (final entry in rawProps.entries) {
      if (entry.key == 'structures' || entry.key == 'estruturas' || entry.key == 'grouped_icons' || entry.key == 'grouped_colors') continue;
      map[entry.key] = entry.value;
    }
    return map;
  }

  List<Map<String, dynamic>> _getStructures() {
    final rawProps = node?.properties ?? feature?.properties ?? {};
    final structs = rawProps['structures'] ?? rawProps['estruturas'];
    if (structs is List) {
      return structs.whereType<Map<String, dynamic>>().toList();
    }
    if (structs is Map<String, dynamic>) {
      return [structs];
    }
    return [];
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required IconData icon}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCoordinatesCard(BuildContext context) {
    final theme = Theme.of(context);
    final lat = node?.latitude ?? (feature?.geometry is hub.NetworkPointGeometry ? (feature!.geometry as hub.NetworkPointGeometry).coordinate.latitude : 0.0);
    final lng = node?.longitude ?? (feature?.geometry is hub.NetworkPointGeometry ? (feature!.geometry as hub.NetworkPointGeometry).coordinate.longitude : 0.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coordenadas (Lat, Lng)',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 2),
                Text(
                  '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesCard(BuildContext context, Map<String, dynamic> properties) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (final entry in properties.entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatKey(entry.key),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${entry.value}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            if (entry.key != properties.keys.last)
              Divider(height: 1, color: theme.colorScheme.outlineVariant.withAlpha(50)),
          ],
        ],
      ),
    );
  }

  Widget _buildStructureCard(BuildContext context, Map<String, dynamic> structure) {
    final theme = Theme.of(context);
    final name = structure['title'] ?? structure['name'] ?? structure['nome'] ?? structure['type'] ?? structure['tipo'] ?? structure['layer'] ?? 'Estrutura';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$name',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final entry in structure.entries)
            if (entry.key != 'title' && entry.key != 'name' && entry.key != 'nome' && entry.key != 'type' && entry.key != 'tipo' && entry.key != 'layer')
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatKey(entry.key),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                    Text(
                      '${entry.value}',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
