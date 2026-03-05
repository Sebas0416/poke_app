import 'package:poke_app/features/pokemon/domain/entities/pokemon_detail_entity.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_stat_entity.dart';

class PokemonDetailModel extends PokemonDetailEntity {
  const PokemonDetailModel({
    required super.id,
    required super.name,
    required super.types,
    required super.height,
    required super.weight,
    required super.baseExperience,
    required super.stats,
    required super.abilities,
  });

  factory PokemonDetailModel.fromJson(Map<String, dynamic> json) {
    final stats = (json['stats'] as List)
        .map((s) => PokemonStatEntity(
              name: s['stat']['name'] as String,
              baseStat: s['base_stat'] as int,
            ))
        .toList();

    return PokemonDetailModel(
      id: json['id'] as int,
      name: json['name'] as String,
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      height: json['height'] as int,
      weight: json['weight'] as int,
      baseExperience: (json['base_experience'] as int?) ?? 0,
      stats: stats,
      abilities: (json['abilities'] as List)
          .map((a) => a['ability']['name'] as String)
          .toList(),
    );
  }
}
