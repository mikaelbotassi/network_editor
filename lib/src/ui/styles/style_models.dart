import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class NetworkEditorMarkerStyle {
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const NetworkEditorMarkerStyle({
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });
}

class NetworkEditorSegmentStyle {
  final Color color;
  final double width;
  final StrokePattern strokePattern;

  const NetworkEditorSegmentStyle({
    required this.color,
    required this.width,
    this.strokePattern = const StrokePattern.solid(),
  });
}