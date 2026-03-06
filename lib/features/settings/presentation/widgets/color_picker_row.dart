import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_app/core/providers/theme_provider.dart';

class ColorPickerRow extends ConsumerWidget {
  const ColorPickerRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedColor = ref.watch(themeColorProvider);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: appColors.map((appColor) {
        final isSelected =
            selectedColor.toARGB32() == appColor.color.toARGB32();
        return GestureDetector(
          onTap: () => ref.read(themeColorProvider.notifier).setColor(
                appColor.color,
              ),
          child: Tooltip(
            message: appColor.name,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appColor.color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: appColor.color.withAlpha(150),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
