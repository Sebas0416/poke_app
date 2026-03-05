import 'package:poke_app/features/pokemon/domain/entities/pokemon_entity.dart';

class PokemonModel extends PokemonEntity {
  const PokemonModel({
    required super.id,
    required super.name,
    required super.types,
  });

  factory PokemonModel.fromListJson(Map<String, dynamic> json) {
    final urlParts = (json['url'] as String).split('/');
    final id = int.parse(urlParts[urlParts.length - 2]);
    return PokemonModel(
      id: id,
      name: json['name'] as String,
      types: const [],
    );
  }

  factory PokemonModel.fromDetailJson(Map<String, dynamic> json) {
    return PokemonModel(
      id: json['id'] as int,
      name: json['name'] as String,
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
    );
  }
}
