import 'package:equatable/equatable.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_stat_entity.dart';

class PokemonDetailEntity extends Equatable {
  final int id;
  final String name;
  final List<String> types;
  final int height;
  final int weight;
  final int baseExperience;
  final List<PokemonStatEntity> stats;
  final List<String> abilities;

  const PokemonDetailEntity({
    required this.id,
    required this.name,
    required this.types,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.stats,
    required this.abilities,
  });

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/'
      'sprites/pokemon/other/official-artwork/$id.png';

  double get heightInMeters => height / 10;

  double get weightInKg => weight / 10;

  @override
  List<Object> get props => [id, name, types];
}
