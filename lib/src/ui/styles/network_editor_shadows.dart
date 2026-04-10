import 'package:flutter/material.dart';

abstract final class NetworkEditorShadows {
  /// Sombra padrão para botões sobrepostos no mapa.
  static const List<BoxShadow> floatingButton = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  /// Sombra padrão para toolbars e painéis pequenos.
  static const List<BoxShadow> overlayPanel = [
    BoxShadow(
      color: Color(0x2E000000),
      blurRadius: 18,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 6,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// Sombra mais forte para menus/context actions.
  static const List<BoxShadow> elevatedOverlay = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 3),
    ),
  ];

  /// Sombra discreta para chips e mini ações.
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];
}