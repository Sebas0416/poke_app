import 'package:flutter/material.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_stat_entity.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_stat_bar.dart';

class DetailStats extends StatelessWidget {
  final List<PokemonStatEntity> stats;
  final Color typeColor;

  const DetailStats({
    super.key,
    required this.stats,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          ...stats.map(
            (stat) => PokemonStatBar(
              name: stat.name,
              value: stat.baseStat,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }
}
