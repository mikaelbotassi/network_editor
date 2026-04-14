import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:simple_painter/simple_painter.dart';

class NetworkImageEditorPage extends StatefulWidget {
  final File sourceFile;

  const NetworkImageEditorPage({
    super.key,
    required this.sourceFile,
  });

  @override
  State<NetworkImageEditorPage> createState() => _NetworkImageEditorPageState();
}

class _NetworkImageEditorPageState extends State<NetworkImageEditorPage> {
  final PainterController _controller = PainterController();
  bool _loading = true;
  Uint8List? _backgroundBytes;

  @override
  void initState() {
    super.initState();
    _loadBackground();
  }

  Future<void> _loadBackground() async {
    final bytes = await widget.sourceFile.readAsBytes();
    await _controller.setBackgroundImage(bytes);

    if (!mounted) return;

    setState(() {
      _backgroundBytes = bytes;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final imageBytes = await _controller.renderImage();

    if (imageBytes == null) return;

    final outputFile = File(
      '${widget.sourceFile.parent.path}/map_after_edit.png',
    );

    await outputFile.writeAsBytes(imageBytes, flush: true);

    if (!mounted) return;
    Navigator.of(context).pop(outputFile);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar mapa'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: PainterWidget(
        controller: _controller,
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _controller.toggleDrawing,
              icon: const Icon(Icons.brush),
            ),
            IconButton(
              onPressed: _controller.toggleErasing,
              icon: const Icon(Icons.cleaning_services),
            ),
            IconButton(
              onPressed: () async {
                await _controller.addText('Texto');
              },
              icon: const Icon(Icons.text_fields),
            ),
          ],
        ),
      ),
    );
  }
}