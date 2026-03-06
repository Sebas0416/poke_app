import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_app/features/pokemon/presentation/providers/pokemon_provider.dart';

class PokemonCounter extends ConsumerWidget {
  const PokemonCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredPokemonProvider);
    final pokemonState = ref.watch(pokemonListProvider);
    final total =
        pokemonState is PokemonListLoaded ? pokemonState.pokemon.length : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(
            Icons.catching_pokemon,
            size: 16,
            color: Colors.white.withAlpha(150),
          ),
          const SizedBox(width: 6),
          Text(
            '${filtered.length} de $total Pokémon',
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
