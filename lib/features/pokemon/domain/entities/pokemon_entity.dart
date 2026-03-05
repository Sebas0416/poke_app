import 'package:equatable/equatable.dart';

class PokemonEntity extends Equatable {
  final int id;
  final String name;
  final List<String> types;

  const PokemonEntity({
    required this.id,
    required this.name,
    required this.types,
  });

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/'
      'sprites/pokemon/other/official-artwork/$id.png';

  @override
  List<Object> get props => [id, name, types];
}
