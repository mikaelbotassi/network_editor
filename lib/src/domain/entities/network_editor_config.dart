class NetworkEditorConfig {
  final bool allowAddPole;
  final bool allowAddTransformer;
  final bool allowConnectPrimaryNetwork;
  final bool allowDeleteNode;
  final bool allowMoveNode;
  final bool allowEditLabels;
  final bool readOnly;

  const NetworkEditorConfig({
    this.allowAddPole = true,
    this.allowAddTransformer = true,
    this.allowConnectPrimaryNetwork = true,
    this.allowDeleteNode = true,
    this.allowMoveNode = true,
    this.allowEditLabels = true,
    this.readOnly = false,
  });
}