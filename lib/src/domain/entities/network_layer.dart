import 'package:flutter/material.dart';

sealed class NetworkBaseLayer {
  const NetworkBaseLayer();
}

class MbtilesBaseLayer extends NetworkBaseLayer {
  final String filePath;

  const MbtilesBaseLayer(this.filePath);
}

class SolidColorBaseLayer extends NetworkBaseLayer {
  final Color color;

  const SolidColorBaseLayer(this.color);
}