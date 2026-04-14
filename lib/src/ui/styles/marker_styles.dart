import 'package:network_editor/src/ui/styles/style_models.dart';
import 'package:flutter/material.dart';

abstract final class NetworkEditorDefaultMarkerStyles {
  static const NetworkEditorMarkerStyle slate = NetworkEditorMarkerStyle(
    fillColor: Color(0xFF94A3B8),
    strokeColor: Color(0xFF0F172A),
    strokeWidth: 1.8,
  );

  static const NetworkEditorMarkerStyle blue = NetworkEditorMarkerStyle(
    fillColor: Color(0xFF2563EB),
    strokeColor: Color(0xFFFFFFFF),
    strokeWidth: 2.0,
  );

  static const NetworkEditorMarkerStyle sky = NetworkEditorMarkerStyle(
    fillColor: Color(0xFF0EA5E9),
    strokeColor: Color(0xFF082F49),
    strokeWidth: 1.8,
  );

  static const NetworkEditorMarkerStyle emerald = NetworkEditorMarkerStyle(
    fillColor: Color(0xFF10B981),
    strokeColor: Color(0xFFFFFFFF),
    strokeWidth: 2.0,
  );

  static const NetworkEditorMarkerStyle amber = NetworkEditorMarkerStyle(
    fillColor: Color(0xFFF59E0B),
    strokeColor: Color(0xFF111827),
    strokeWidth: 2.0,
  );

  static const NetworkEditorMarkerStyle orange = NetworkEditorMarkerStyle(
    fillColor: Color(0xFFF97316),
    strokeColor: Color(0xFFFFFFFF),
    strokeWidth: 2.0,
  );

  static const NetworkEditorMarkerStyle red = NetworkEditorMarkerStyle(
    fillColor: Color(0xFFEF4444),
    strokeColor: Color(0xFFFFFFFF),
    strokeWidth: 2.2,
  );

  static const NetworkEditorMarkerStyle rose = NetworkEditorMarkerStyle(
    fillColor: Color(0xFFE11D48),
    strokeColor: Color(0xFFFFFFFF),
    strokeWidth: 2.2,
  );

  static const NetworkEditorMarkerStyle violet = NetworkEditorMarkerStyle(
    fillColor: Color(0xFF8B5CF6),
    strokeColor: Color(0xFFFFFFFF),
    strokeWidth: 2.0,
  );

  static const NetworkEditorMarkerStyle zinc = NetworkEditorMarkerStyle(
    fillColor: Color(0xFF52525B),
    strokeColor: Color(0xFFFFFFFF),
    strokeWidth: 1.8,
  );

  static const List<NetworkEditorMarkerStyle> values = [
    slate,
    blue,
    sky,
    emerald,
    amber,
    orange,
    red,
    rose,
    violet,
    zinc,
  ];
}