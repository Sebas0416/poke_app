import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_app/features/pokemon/presentation/providers/pokemon_provider.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_type_chip.dart';

const _types = [
  'fire',
  'water',
  'grass',
  'electric',
  'psychic',
  'ice',
  'dragon',
  'dark',
  'fairy',
  'normal',
  'fighting',
  'flying',
  'poison',
  'ground',
  'rock',
  'bug',
  'ghost',
  'steel',
];

class TypeFilterRow extends ConsumerWidget {
  const TypeFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedTypeProvider);

    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _types.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedType == null;
            return GestureDetector(
              onTap: () => ref.read(selectedTypeProvider.notifier).state = null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE94560)
                      : Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.white.withAlpha(60)),
                ),
                child: const Text(
                  'TODOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            );
          }

          final type = _types[index - 1];
          final isSelected = selectedType == type;
          final color = PokemonTypeChip.typeColor(type);

          return GestureDetector(
            onTap: () => ref.read(selectedTypeProvider.notifier).state =
                isSelected ? null : type,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withAlpha(60),
                borderRadius: BorderRadius.circular(20),
                border:
                    isSelected ? null : Border.all(color: color.withAlpha(120)),
              ),
              child: Text(
                type.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
