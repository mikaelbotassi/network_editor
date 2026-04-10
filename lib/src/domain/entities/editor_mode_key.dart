import 'package:flutter/foundation.dart';

/// =======================================================
/// MODE KEY
/// =======================================================

@immutable
final class EditorModeKey {
  final String value;

  const EditorModeKey._(this.value);

  static const view = EditorModeKey._('view');
  static const move = EditorModeKey._('move');
  static const delete = EditorModeKey._('delete');
  static const connect = EditorModeKey._('connect');

  factory EditorModeKey.custom(String value) {
    assert(value.trim().isNotEmpty, 'Custom mode value cannot be empty.');
    return EditorModeKey._(value.trim());
  }

  bool get isBuiltIn =>
      this == view || this == move || this == delete || this == connect;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EditorModeKey && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'EditorModeKey($value)';
}