import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_evolution_entity.dart';
import 'package:shimmer/shimmer.dart';

class EvolutionCard extends StatelessWidget {
  final PokemonEvolutionEntity evolution;
  final Color typeColor;

  const EvolutionCard({
    super.key,
    required this.evolution,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withAlpha(80)),
      ),
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: evolution.imageUrl,
            height: 72,
            width: 72,
            fit: BoxFit.contain,
            placeholder: (_, __) => Shimmer.fromColors(
              baseColor: Colors.white.withAlpha(20),
              highlightColor: Colors.white.withAlpha(60),
              child: Container(
                height: 72,
                width: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Icon(
              Icons.catching_pokemon,
              size: 40,
              color: typeColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            evolution.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
