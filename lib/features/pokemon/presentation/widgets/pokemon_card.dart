import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_entity.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_type_chip.dart';
import 'package:shimmer/shimmer.dart';

class PokemonCard extends StatelessWidget {
  final PokemonEntity pokemon;
  final bool isCenter;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.isCenter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryType = pokemon.types.firstOrNull ?? 'normal';
    final color = PokemonTypeChip.typeColor(primaryType);

    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      scale: isCenter ? 1.0 : 0.82,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isCenter ? 1.0 : 0.5,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withAlpha(180),
                  color.withAlpha(80),
                ],
              ),
              boxShadow: isCenter
                  ? [
                      BoxShadow(
                        color: color.withAlpha(120),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    Icons.catching_pokemon,
                    size: 140,
                    color: Colors.white.withAlpha(20),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'pokemon_${pokemon.id}',
                      child: CachedNetworkImage(
                        imageUrl: pokemon.imageUrl,
                        height: 160,
                        width: 160,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: Colors.white.withAlpha(40),
                          highlightColor: Colors.white.withAlpha(80),
                          child: Container(
                            height: 160,
                            width: 160,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.catching_pokemon,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pokemon.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pokemon.types
                          .map((t) => PokemonTypeChip(type: t))
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
