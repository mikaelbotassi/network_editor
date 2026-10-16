import 'package:flutter/material.dart';
import 'package:electric_shapes/electric_shapes.dart';

enum TipoPoste {
  acoCircular(1, 'Aço Circular', ElectricIcons.posteMadeiraExistente),
  concretoCircular(
    2,
    'Concreto Circular',
    ElectricIcons.posteConcretoCircularExistente,
  ),
  concretoDuploT(3, 'Concreto Duplo T', ElectricIcons.posteConcretoDTExistente),
  concretoOrnamental(
    4,
    'Concreto Ornamental',
    ElectricIcons.posteMadeiraExistente,
  ),
  madeira(5, 'Madeira', ElectricIcons.posteMadeiraExistente),
  acoQuadrado(6, 'Aço Quadrado', ElectricIcons.posteMadeiraExistente),
  retangular(7, 'Retangular', ElectricIcons.posteMadeiraExistente),
  torre(8, 'Torre', ElectricIcons.posteMadeiraExistente),
  fibraCircular(9, 'Fibra Circular', ElectricIcons.posteFibraVidroExistente),
  fibraDuploT(10, 'Fibra Duplo T', ElectricIcons.posteMadeiraExistente);

  final int value;
  final String label;
  final IconData icon;
  const TipoPoste(this.value, this.label, this.icon);

  factory TipoPoste.fromValue(int value) {
    return TipoPoste.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoPoste.madeira,
    );
  }
}
