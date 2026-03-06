import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_app/core/widgets/gradient_background.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_detail_entity.dart';
import 'package:poke_app/features/pokemon/presentation/providers/pokemon_provider.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/detail_abilities.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/detail_header.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/detail_stats.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/evolution_bottom_sheet.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_info_chip.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_type_chip.dart';
import 'package:shimmer/shimmer.dart';

class DetailPage extends ConsumerWidget {
  final int pokemonId;
  final String pokemonName;

  const DetailPage({
    super.key,
    required this.pokemonId,
    required this.pokemonName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(pokemonDetailProvider(pokemonId));

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: switch (detailState) {
            PokemonDetailLoading() ||
            PokemonDetailInitial() =>
              _buildLoading(context),
            PokemonDetailError(:final message) =>
              _buildError(context, message, ref),
            PokemonDetailLoaded(:final pokemon) =>
              _buildDetail(context, pokemon),
            PokemonDetailState() => throw UnimplementedError(),
          },
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, PokemonDetailEntity pokemon) {
    final primaryType = pokemon.types.firstOrNull ?? 'normal';
    final typeColor = PokemonTypeChip.typeColor(primaryType);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: DetailHeader(pokemon: pokemon, typeColor: typeColor),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: PokemonInfoChip(
                    icon: Icons.height,
                    label: 'Altura',
                    value: '${pokemon.heightInMeters} m',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PokemonInfoChip(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Peso',
                    value: '${pokemon.weightInKg} kg',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PokemonInfoChip(
                    icon: Icons.star_outline,
                    label: 'Exp. base',
                    value: pokemon.baseExperience.toString(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () => EvolutionBottomSheet.show(
                context,
                pokemonId: pokemonId,
                typeColor: typeColor,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [typeColor, typeColor.withAlpha(180)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withAlpha(100),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Ver evolución',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: DetailAbilities(
            abilities: pokemon.abilities,
            typeColor: typeColor,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: DetailStats(stats: pokemon.stats, typeColor: typeColor),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.white.withAlpha(30),
            highlightColor: Colors.white.withAlpha(80),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 28,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar la información de $pokemonName',
              style: TextStyle(color: Colors.white.withAlpha(180)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(pokemonDetailProvider(pokemonId).notifier)
                  .loadDetail(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
