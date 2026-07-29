# Network Editor

Pacote Flutter para visualizar e editar redes sobre `flutter_map`. No Android,
as estruturas corporativas são consultadas offline no SMRE Hub por meio do
`smre_network_client`.

## Rede do SMRE Hub

O editor consulta somente os tiles XYZ do viewport visível. A câmera possui
debounce de 180 ms, respostas de viewports antigos são ignoradas e features que
atravessam mais de um tile são deduplicadas.

As camadas respeitam os zooms mínimos definidos pelo Hub:

| Camada | Zoom mínimo |
|---|---:|
| Rede primária | 11 |
| Rede secundária | 14 |
| Transformadores, seccionadoras, capacitores, reguladores e medição | 15 |
| Postes | 17 |

Linhas e pontos do Hub são desenhados em Canvas. Os nós e segmentos editáveis
continuam sendo renderizados por cima dessas estruturas de referência.

## Requisitos Android

- SMRE Hub instalado e com as camadas sincronizadas.
- Aplicativo consumidor e Hub assinados pelo mesmo certificado.
- Android API 24 ou superior.

O manifesto do cliente adiciona automaticamente a permissão
`com.elfsm.smre_hub.permission.READ_NETWORK_DATA`.

## Uso

```dart
final controller = NetworkEditorController(
  initialCenter: const LatLng(-19.5356, -40.6306),
  initialZoom: 17,
  initialValue: const NetworkEditorValue(),
);

NetworkEditorWidget(
  controller: controller,
  showHubNetwork: true,
  initialVisibleNetworkLayers: {
    NetworkLayer.redePrimaria,
    NetworkLayer.poste,
    NetworkLayer.transformador,
  },
  onNetworkFeatureTap: (feature) {
    print('${feature.layer.name}: ${feature.title ?? feature.id}');
  },
);
```

`showHubNetwork` é `true` por padrão. O botão de camadas no canto superior
direito permite habilitar ou ocultar cada tipo de estrutura em tempo de
execução.
