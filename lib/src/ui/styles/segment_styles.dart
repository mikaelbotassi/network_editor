import 'dart:ui';

import 'package:network_editor/src/ui/styles/style_models.dart';
import 'package:flutter_map/flutter_map.dart';

abstract final class NetworkEditorDefaultSegmentStyles {
  static const NetworkEditorSegmentStyle blueBold = NetworkEditorSegmentStyle(
    color: Color(0xFF2563EB),
    width: 4.0,
    strokePattern: StrokePattern.solid(),
  );

  static const NetworkEditorSegmentStyle skyMedium = NetworkEditorSegmentStyle(
    color: Color(0xFF0EA5E9),
    width: 3.2,
    strokePattern: StrokePattern.solid(),
  );

  static const NetworkEditorSegmentStyle emeraldMedium = NetworkEditorSegmentStyle(
    color: Color(0xFF10B981),
    width: 3.2,
    strokePattern: StrokePattern.solid(),
  );

  static NetworkEditorSegmentStyle amberDashed = NetworkEditorSegmentStyle(
    color: Color(0xFFF59E0B),
    width: 3.6,
    strokePattern: StrokePattern.dashed(segments: [10, 6]),
  );

  static const NetworkEditorSegmentStyle redDotted = NetworkEditorSegmentStyle(
    color: Color(0xFFEF4444),
    width: 3.8,
    strokePattern: StrokePattern.dotted(spacingFactor: 1.6),
  );

  static List<NetworkEditorSegmentStyle> values = [
    blueBold,
    skyMedium,
    emeraldMedium,
    amberDashed,
    redDotted,
  ];
}