import 'package:equatable/equatable.dart';

class PokemonStatEntity extends Equatable {
  final String name;
  final int baseStat;

  const PokemonStatEntity({
    required this.name,
    required this.baseStat,
  });

  @override
  List<Object> get props => [name, baseStat];
}
