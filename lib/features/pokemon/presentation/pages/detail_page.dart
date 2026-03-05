import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_app/core/widgets/gradient_background.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_detail_entity.dart';
import 'package:poke_app/features/pokemon/presentation/providers/pokemon_provider.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_info_chip.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_stat_bar.dart';
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -40,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: typeColor.withAlpha(40),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        Text(
                          '#${pokemon.id.toString().padLeft(3, '0')}',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Hero(
                    tag: 'pokemon_${pokemon.id}',
                    child: CachedNetworkImage(
                      imageUrl: pokemon.imageUrl,
                      height: 200,
                      width: 200,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.white.withAlpha(40),
                        highlightColor: Colors.white.withAlpha(80),
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.catching_pokemon,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pokemon.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pokemon.types
                        .map((t) => PokemonTypeChip(type: t))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
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
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Habilidades',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: pokemon.abilities
                      .map(
                        (a) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withAlpha(60),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: typeColor.withAlpha(120),
                            ),
                          ),
                          child: Text(
                            a.replaceAll('-', ' ').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estadísticas base',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...pokemon.stats.map(
                  (stat) => PokemonStatBar(
                    name: stat.name,
                    value: stat.baseStat,
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            message,
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
    );
  }
}
