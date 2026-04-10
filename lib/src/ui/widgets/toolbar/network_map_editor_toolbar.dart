import 'package:electric_digital_sketch/electric_digital_sketch.dart';
import 'package:electric_digital_sketch/src/domain/entities/editor_mode_key.dart';
import 'package:electric_digital_sketch/src/ui/widgets/toolbar/network_map_editor_menu_button.dart';
import 'package:electric_digital_sketch/src/ui/widgets/toolbar/network_map_toolbar_item.dart';
import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class NetworkMapEditorToolbar extends StatefulWidget {
  final NetworkEditorController controller;
  final List<ToolbarActionItem> items;

  const NetworkMapEditorToolbar({
    super.key,
    required this.controller,
    this.items = const [],
  });

  @override
  State<NetworkMapEditorToolbar> createState() => _NetworkMapEditorToolbarState();
}

class _NetworkMapEditorToolbarState extends State<NetworkMapEditorToolbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _expanded = false;

  final List<ToolbarActionItem> _items = [
    ToolbarActionItem(
      icon: TablerIcons.handFinger,
      mode: EditorModeKey.view,
      tooltip: 'Visualizar',
    ),
    ToolbarActionItem(
      icon: TablerIcons.arrowsMove,
      mode: EditorModeKey.move,
      tooltip: 'Mover',
    ),
    ToolbarActionItem(
      icon: TablerIcons.trash,
      mode: EditorModeKey.delete,
      tooltip: 'Excluir',
    ),
  ];

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

  void _selectMode(EditorModeKey mode) {
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
                  children: List.generate(_items.length, (index) {
                    final item = _items[index];
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