import 'package:electric_digital_sketch/electric_digital_sketch.dart';
import 'package:electric_digital_sketch/src/domain/enums/network_edit_mode.dart';
import 'package:electric_digital_sketch/src/ui/widgets/toolbar/network_map_editor_menu_button.dart';
import 'package:electric_digital_sketch/src/ui/widgets/toolbar/network_map_toolbar_item.dart';
import 'package:flutter/material.dart';

class NetworkMapEditorToolbar extends StatefulWidget {
  final NetworkEditorController controller;

  const NetworkMapEditorToolbar({
    super.key,
    required this.controller,
  });

  @override
  State<NetworkMapEditorToolbar> createState() => _NetworkMapEditorToolbarState();
}

class _NetworkMapEditorToolbarState extends State<NetworkMapEditorToolbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _expanded = false;

  final List<ToolbarActionItem> _items = const [
    ToolbarActionItem(
      icon: Icons.pan_tool_alt,
      mode: NetworkEditMode.view,
      tooltip: 'Visualizar',
    ),
    ToolbarActionItem(
      icon: Icons.add_location_alt,
      mode: NetworkEditMode.addPole,
      tooltip: 'Novo poste',
    ),
    ToolbarActionItem(
      icon: Icons.add_business,
      mode: NetworkEditMode.addTransformer,
      tooltip: 'Novo trafo',
    ),
    ToolbarActionItem(
      icon: Icons.timeline,
      mode: NetworkEditMode.connectPrimary,
      tooltip: 'Ligar rede',
    ),
    ToolbarActionItem(
      icon: Icons.open_with,
      mode: NetworkEditMode.moveNode,
      tooltip: 'Mover',
    ),
    ToolbarActionItem(
      icon: Icons.delete,
      mode: NetworkEditMode.delete,
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

  void _selectMode(NetworkEditMode mode) {
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

                    return Padding(
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