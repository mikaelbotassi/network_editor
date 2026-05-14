import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class SnaphotSelectorAppbar extends StatelessWidget implements PreferredSizeWidget {
  const SnaphotSelectorAppbar({
    super.key,
  });


  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (colors,textTheme) = (theme.colorScheme, theme.textTheme);
    return Container(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      color: colors.surfaceContainerLowest,
      child: SafeArea(
        bottom: false,
        child: Row(
          spacing: 8,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                TablerIcons.chevronLeft,
                color: colors.onSurfaceVariant,
              ),
            ),
            Text(
              'Selecionar area do mapa',
              style: textTheme.titleLarge,
            )
          ],
        ),
      ),
    );
  }
}
