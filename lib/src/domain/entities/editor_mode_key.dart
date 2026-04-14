import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// =======================================================
/// MODE KEY
/// =======================================================

@immutable
final class EditorMode {

  final IconData icon;
  final String label;
  final String value;

  const EditorMode._({
    required this.label,
    required this.value,
    required this.icon,
  });

  static const view = EditorMode._(
    value: 'view',
    label: 'Visualizar',
    icon: TablerIcons.handFinger,
  );

  static const move = EditorMode._(
    value: 'move',
    icon: TablerIcons.arrowsMove,
    label: 'Mover',
  );

  static const delete = EditorMode._(
    value: 'delete',
    icon: TablerIcons.trash,
    label: 'Excluir',
  );

  static const connect = EditorMode._(
    value: 'connect',
    icon: TablerIcons.line,
    label: 'Novo Segmento'
  );

  factory EditorMode.custom({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final trimValue = value.trim();
    assert(trimValue.isNotEmpty, 'Custom mode value cannot be empty.');
    return EditorMode._(
      value: trimValue,
      label: label,
      icon: icon
    );
  }

  bool get isBuiltIn =>
      this == view || this == move || this == delete || this == connect;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EditorMode && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'EditorModeKey($value)';
}