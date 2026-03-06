import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_detail_entity.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_particles.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_type_chip.dart';
import 'package:shimmer/shimmer.dart';

class DetailHeader extends StatelessWidget {
  final PokemonDetailEntity pokemon;
  final Color typeColor;

  const DetailHeader({
    super.key,
    required this.pokemon,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        PokemonParticles(color: typeColor),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
              children:
                  pokemon.types.map((t) => PokemonTypeChip(type: t)).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ],
    );
  }
}
