import 'package:electric_digital_sketch/src/domain/entities/editor_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class EditorSegment {
  final String id;
  final String groupId;
  final double strokeWidth;
  final Color color;
  final StrokePattern pattern;
  final List<EditorCoordinate> points;
  final String? fromNodeId;
  final String? toNodeId;
  final bool isNew;
  final bool isDeleted;
  final Map<String, dynamic> properties;

  const EditorSegment({
    required this.id,
    required this.groupId,
    required this.points,
    this.strokeWidth = 2,
    this.color = Colors.black,
    this.pattern = const StrokePattern.solid(),
    this.fromNodeId,
    this.toNodeId,
    this.isNew = false,
    this.isDeleted = false,
    this.properties = const {},
  });

  EditorSegment copyWith({
    String? id,
    String? groupId,
    double? strokeWidth,
    Color? color,
    StrokePattern? pattern,
    List<EditorCoordinate>? points,
    String? fromNodeId,
    String? toNodeId,
    bool? isNew,
    bool? isDeleted,
    Map<String, dynamic>? properties,
  }) {
    return EditorSegment(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      color: color ?? this.color,
      pattern: pattern ?? this.pattern,
      points: points ?? this.points,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      isNew: isNew ?? this.isNew,
      isDeleted: isDeleted ?? this.isDeleted,
      properties: properties ?? this.properties,
    );
  }

}