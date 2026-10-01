import 'package:flutter/material.dart';
import 'package:gym_logger/theme/app_colors.dart';

class ColorDropdown extends StatelessWidget {
  const ColorDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AppPalette value;
  final ValueChanged<AppPalette> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<AppPalette>(
      value: value,
      underline: const SizedBox.shrink(),
      items: const [
        DropdownMenuItem(
          value: AppPalette.defaultTheme,
          child: Text('Default Theme'),
        ),
        DropdownMenuItem(
          value: AppPalette.neonTokyo,
          child: Text('Neon Tokyo'),
        ),
      ],
      onChanged: (selection) {
        if (selection != null) onChanged(selection);
      },
    );
  }
}
