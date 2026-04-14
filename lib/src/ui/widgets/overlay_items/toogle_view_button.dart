import 'package:network_editor/network_editor.dart';
import 'package:network_editor/src/domain/enums/network_view.dart';
import 'package:flutter/material.dart';

class ToogleViewButton extends StatelessWidget {

  final VoidCallback onTap;
  final BackgroundView backgroundView;

  const ToogleViewButton({
    super.key,
    required this.onTap,
    this.backgroundView = BackgroundView.map,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          boxShadow: NetworkEditorShadows.elevatedOverlay,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white, width: 2)
        ),
        child: Image.asset(
          assetsUrl, package: 'network_editor',
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String get assetsUrl => backgroundView == BackgroundView.map ? 'assets/images/map-solid-dark.png' : 'assets/images/map.webp';

}