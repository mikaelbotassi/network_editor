import 'package:network_editor/network_editor.dart';
import 'package:network_editor/src/ui/widgets/overlay_items/toolbar/network_map_editor_menu_button.dart';
import 'package:network_editor/src/ui/widgets/overlay_items/toolbar/network_map_toolbar_item.dart';
import 'package:flutter/material.dart';

class NetworkMapEditorToolbar extends StatefulWidget {
  final NetworkEditorController controller;
  final List<ToolbarActionItem> items;

  const NetworkMapEditorToolbar({
    super.key,
    required this.controller,
    required this.items,
  });

  @override
  State<NetworkMapEditorToolbar> createState() => _NetworkMapEditorToolbarState();
}

class _NetworkMapEditorToolbarState extends State<NetworkMapEditorToolbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);

    if (_expanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _selectMode(EditorMode mode) {
    widget.controller.setMode(mode);
    setState(() => _expanded = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, widget.controller]),
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IgnorePointer(
              ignoring: !_expanded,
              child: AnimatedOpacity(
                opacity: _expanded ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final selected = widget.controller.mode == item.mode;

                    return IntrinsicWidth(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            (1 - _animationController.value) * 12,
                          ),
                          child: NetworkMapToolbarItemWidget(
                            icon: item.icon,
                            label: item.tooltip,
                            selected: selected,
                            onTap: () => _selectMode(item.mode),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            NetworkMapEditorMenuButton(
              isActive: _expanded,
              onTap: _toggle,
            )
          ],
        );
      },
    );
  }
}