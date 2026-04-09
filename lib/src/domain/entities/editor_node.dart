import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class EditorNode {
  final String id;
  final String? groupId;
  final String? svgPath;
  final IconData icon;
  final Color color;
  final double latitude;
  final double longitude;
  final String? label;
  final bool isNew;
  final bool isDeleted;
  final Map<String, dynamic> properties;

  EditorNode({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.svgPath,
    this.icon = TablerIcons.circleFilled,
    this.color = Colors.blue,
    this.groupId,
    this.label,
    this.isNew = false,
    this.isDeleted = false,
    this.properties = const {}
  });

  EditorNode copyWith({
    String? id,
    String? groupId,
    String? svgUrl,
    IconData? icon,
    Color? color,
    double? latitude,
    double? longitude,
    String? label,
    bool? isNew,
    bool? isDeleted,
    Map<String, dynamic>? properties,
  }) {
    return EditorNode(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      svgPath: svgUrl ?? this.svgPath,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      label: label ?? this.label,
      isNew: isNew ?? this.isNew,
      isDeleted: isDeleted ?? this.isDeleted,
      properties: properties ?? this.properties,
    );
  }

}