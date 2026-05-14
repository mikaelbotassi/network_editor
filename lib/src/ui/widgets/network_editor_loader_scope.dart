import 'package:flutter/widgets.dart';
import 'package:network_editor/src/ui/viewmodels/network_editor_loader_service.dart';

class NetworkEditorLoaderScope extends InheritedWidget {
  const NetworkEditorLoaderScope({
    super.key,
    required this.loaderService,
    required super.child,
  });

  final NetworkEditorLoaderService loaderService;

  static NetworkEditorLoaderService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<
        NetworkEditorLoaderScope>();
    assert(scope != null, 'NetworkEditorLoaderScope not found in context.');
    return scope!.loaderService;
  }

  @override
  bool updateShouldNotify(covariant NetworkEditorLoaderScope oldWidget) {
    return oldWidget.loaderService != loaderService;
  }
}
