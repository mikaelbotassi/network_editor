import 'package:electric_digital_sketch/src/domain/entities/editor_coordinate.dart';
import 'package:electric_digital_sketch/src/domain/enums/editor_segment_type.dart';

class EditorSegment {
  final String id;
  final EditorSegmentType type;
  final List<EditorCoordinate> points;
  final String? fromNodeId;
  final String? toNodeId;
  final bool isNew;
  final bool isDeleted;
  final Map<String, dynamic> properties;

  const EditorSegment({
    required this.id,
    required this.type,
    required this.points,
    this.fromNodeId,
    this.toNodeId,
    this.isNew = false,
    this.isDeleted = false,
    this.properties = const {},
  });

  EditorSegment copyWith({
    String? id,
    EditorSegmentType? type,
    List<EditorCoordinate>? points,
    String? fromNodeId,
    String? toNodeId,
    bool? isNew,
    bool? isDeleted,
    Map<String, dynamic>? properties,
  }) {
    return EditorSegment(
      id: id ?? this.id,
      type: type ?? this.type,
      points: points ?? this.points,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      isNew: isNew ?? this.isNew,
      isDeleted: isDeleted ?? this.isDeleted,
      properties: properties ?? this.properties,
    );
  }
}