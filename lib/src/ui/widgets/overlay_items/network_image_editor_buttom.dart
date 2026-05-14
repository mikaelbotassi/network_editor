import 'dart:io';

import 'package:electric_digital_sketch/electric_digital_sketch.dart';
import 'package:network_editor/network_editor.dart';
import 'package:network_editor/src/ui/viewmodels/network_editor_snapshot_service.dart';
import 'package:network_editor/src/ui/network_map_snapshot_selector_page.dart';
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
  bool _isPreparingEditor = false;

  Future<File?> openMapEditor() async {
    if (_isPreparingEditor) {
      return null;
    }

    _isPreparingEditor = true;

    try {
      final loaderService = NetworkEditorLoaderScope.of(context);
      final originalSnapshot = await loaderService.runWithLoader(
        context: context,
        title: 'Preparando recorte',
        message: 'Carregando a imagem do mapa para edicao.',
        action: () => _snapshotService.captureToCache(
          boundaryKey: widget.mapCaptureKey,
          fileName: 'map_before_edit_full.png',
        ),
      );

      if (!mounted) return null;

      final backgroundImage = await Navigator.of(context).push<File>(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => NetworkMapSnapshotSelectorPage(
            snapshot: originalSnapshot,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

      if (!mounted || backgroundImage == null) return null;

      final editedFile = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (_) => ElectricSketchPage(
            initialBackgroundImage: backgroundImage,
          ),
        ),
      );

      return editedFile;
    } finally {
      _isPreparingEditor = false;
    }
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
