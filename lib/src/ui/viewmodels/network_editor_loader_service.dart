import 'dart:async';

import 'package:flutter/material.dart';
import 'package:network_editor/src/ui/widgets/overlay_items/network_editor_loader_overlay.dart';

class NetworkEditorLoaderService {
  const NetworkEditorLoaderService();

  NetworkEditorLoaderHandle show({
    required BuildContext context,
    String title = 'Carregando',
    String message = 'Aguarde um instante.',
    bool useRootNavigator = true,
    bool barrierDismissible = false,
  }) {
    final handle = NetworkEditorLoaderHandle._(
      context: context,
      useRootNavigator: useRootNavigator,
    );

    unawaited(
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierLabel: title,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, _, _) => NetworkEditorLoaderOverlay(
          title: title,
          message: message,
        ),
        transitionBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );

    return handle;
  }

  Future<T> runWithLoader<T>({
    required BuildContext context,
    required Future<T> Function() action,
    String title = 'Carregando',
    String message = 'Aguarde um instante.',
    bool useRootNavigator = true,
    bool barrierDismissible = false,
  }) async {
    final handle = show(
      context: context,
      title: title,
      message: message,
      useRootNavigator: useRootNavigator,
      barrierDismissible: barrierDismissible,
    );

    try {
      return await action();
    } finally {
      handle.close();
    }
  }
}

class NetworkEditorLoaderHandle {
  NetworkEditorLoaderHandle._({
    required this.context,
    required this.useRootNavigator,
  });

  final BuildContext context;
  final bool useRootNavigator;
  bool _closed = false;

  void close() {
    if (_closed || !context.mounted) {
      return;
    }

    _closed = true;
    Navigator.of(context, rootNavigator: useRootNavigator).pop();
  }
}
