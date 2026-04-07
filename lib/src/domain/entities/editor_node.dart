import 'package:electric_digital_sketch/src/domain/enums/editor_node_type.dart';

class EditorNode {
  final String id;
  final EditorNodeType type;
  final double latitude;
  final double longitude;
  final String? label;
  final bool isNew;
  final bool isDeleted;
  final Map<String, dynamic> properties;

  const EditorNode({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.label,
    this.isNew = false,
    this.isDeleted = false,
    this.properties = const {},
  });

  EditorNode copyWith({
    String? id,
    EditorNodeType? type,
    double? latitude,
    double? longitude,
    String? label,
    bool? isNew,
    bool? isDeleted,
    Map<String, dynamic>? properties,
  }) {
    return EditorNode(
      id: id ?? this.id,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      label: label ?? this.label,
      isNew: isNew ?? this.isNew,
      isDeleted: isDeleted ?? this.isDeleted,
      properties: properties ?? this.properties,
    );
  }
}