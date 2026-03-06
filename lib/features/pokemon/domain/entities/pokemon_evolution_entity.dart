class PokemonEvolutionEntity {
  final int id;
  final String name;

  const PokemonEvolutionEntity({required this.id, required this.name});

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}
