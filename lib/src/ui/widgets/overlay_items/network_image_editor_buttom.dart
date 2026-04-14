import 'dart:io';

import 'package:network_editor/network_editor.dart';
import 'package:network_editor/src/ui/network_image_editor_page.dart';
import 'package:network_editor/src/ui/viewmodels/network_editor_snapshot_service.dart';
import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class NetworkImageEditorButtom extends StatefulWidget {

  final GlobalKey mapCaptureKey;

  const NetworkImageEditorButtom({
    super.key,
    required this.mapCaptureKey
  });

  @override
  State<NetworkImageEditorButtom> createState() => _NetworkImageEditorButtomState();
}

class _NetworkImageEditorButtomState extends State<NetworkImageEditorButtom> {

  final _snapshotService = NetworkEditorSnapshotService();

  Future<File?> openMapEditor() async {
    final originalFile = await _snapshotService.captureToCache(
      boundaryKey: widget.mapCaptureKey,
      fileName: 'map_before_edit.png',
    );

    if (!mounted) return null;

    final editedFile = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (_) => NetworkImageEditorPage(
          sourceFile: originalFile,
        ),
      ),
    );

    return editedFile;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: openMapEditor,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colors.primary),
          boxShadow: NetworkEditorShadows.overlayPanel
        ),
        child: Icon(TablerIcons.edit, color: colors.primary),
      )
    );
  }
}
