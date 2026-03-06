import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_evolution_entity.dart';
import 'package:poke_app/features/pokemon/presentation/providers/pokemon_provider.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/evolution_card.dart';
import 'package:shimmer/shimmer.dart';

class EvolutionBottomSheet extends ConsumerWidget {
  final int pokemonId;
  final Color typeColor;

  const EvolutionBottomSheet({
    super.key,
    required this.pokemonId,
    required this.typeColor,
  });

  static Future<void> show(
    BuildContext context, {
    required int pokemonId,
    required Color typeColor,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EvolutionBottomSheet(
        pokemonId: pokemonId,
        typeColor: typeColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evolutionsAsync = ref.watch(pokemonEvolutionsProvider(pokemonId));

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Título
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: typeColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Cadena de evolución',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          evolutionsAsync.when(
            loading: () => _buildLoading(),
            error: (_, __) => _buildError(),
            data: (evolutions) => evolutions.length <= 1
                ? _buildNoEvolutions()
                : _buildEvolutions(evolutions),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEvolutions(List<PokemonEvolutionEntity> evolutions) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < evolutions.length; i++) ...[
            EvolutionCard(evolution: evolutions[i], typeColor: typeColor),
            if (i < evolutions.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: typeColor,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'evoluciona',
                      style: TextStyle(
                        color: Colors.white.withAlpha(100),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withAlpha(20),
      highlightColor: Colors.white.withAlpha(60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (_) => Container(
            width: 80,
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.white.withAlpha(100)),
          const SizedBox(height: 8),
          Text(
            'No se pudo cargar la evolución',
            style: TextStyle(color: Colors.white.withAlpha(100)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEvolutions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.catching_pokemon,
            size: 48,
            color: Colors.white.withAlpha(60),
          ),
          const SizedBox(height: 12),
          Text(
            'Este Pokémon no tiene evoluciones',
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
