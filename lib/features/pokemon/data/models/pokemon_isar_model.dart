import 'package:isar_community/isar.dart';

part 'pokemon_isar_model.g.dart';

@collection
class PokemonIsarModel {
  Id get isarId => id;

  late int id;
  late String name;
  late List<String> types;
  late DateTime cachedAt;
}

@collection
class PokemonDetailIsarModel {
  Id get isarId => id;

  late int id;
  late String name;
  late List<String> types;
  late int height;
  late int weight;
  late int baseExperience;
  late List<String> statNames;
  late List<int> statValues;
  late List<String> abilities;
  late DateTime cachedAt;
}
