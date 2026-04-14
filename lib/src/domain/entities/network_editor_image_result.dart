import 'dart:io';

class NetworkEditorImageResult {
  final File originalFile;
  final File editedFile;

  const NetworkEditorImageResult({
    required this.originalFile,
    required this.editedFile,
  });
}