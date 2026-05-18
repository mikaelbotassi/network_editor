import 'package:electric_shapes/electric_shapes.dart';
import 'package:flutter/material.dart';
import 'package:network_editor_example/src/ui/widgets/coords_input/coords_input.dart';
import 'package:network_editor_example/src/ui/widgets/toggle_button/toggle_button_group.dart';

class PoleDetailDialog extends StatelessWidget {
  const PoleDetailDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (colors,textTheme) = (theme.colorScheme, theme.textTheme);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 32,
        children: [
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: colors.onSurface.withAlpha(50),
              borderRadius: BorderRadius.circular(4)
            ),
          ),
          Text('Adicionar Poste', style: textTheme.titleLarge),
          CoordsInput(),
          SingleChildScrollView(
            scrollDirection: .horizontal,
            child: ToggleButtonGroup(
              onChanged: (newValue){},
              initialValue: 'poste concreto DT',
              options: options,
            ),
          )
        ],
      ),
    );
  }

  List<ToggleButtonOption<String>> get options => [
    ToggleButtonOption(
      value: 'poste concreto DT',
      text: 'Poste Concreto DT',
      icon: ElectricIcons.posteConcretoDTProjetado
    ),
    ToggleButtonOption(
      value: 'poste concreto circular',
      text: 'Poste Concreto Circular',
      icon: ElectricIcons.posteConcretoCircularProjetado
    ),
    ToggleButtonOption(
      value: 'poste fibra',
      text: 'Poste Fibra de vidro',
      icon: ElectricIcons.posteFibraVidroProjetado
    )
  ];

}
