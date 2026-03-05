import 'package:isar_community/isar.dart';
import 'package:poke_app/features/pokemon/data/models/pokemon_isar_model.dart';

abstract class PokemonLocalDatasource {
  Future<List<PokemonIsarModel>?> getCachedPokemonList();
  Future<PokemonDetailIsarModel?> getCachedPokemonDetail(int id);
  Future<void> cachePokemonList(List<PokemonIsarModel> pokemon);
  Future<void> cachePokemonDetail(PokemonDetailIsarModel detail);
  Future<bool> hasCachedData();
}

class PokemonLocalDatasourceImpl implements PokemonLocalDatasource {
  final Isar _isar;

  static const Duration _cacheValidity = Duration(hours: 24);

  const PokemonLocalDatasourceImpl(this._isar);

  @override
  Future<List<PokemonIsarModel>?> getCachedPokemonList() async {
    final cached = await _isar.pokemonIsarModels.where().findAll();
    if (cached.isEmpty) return null;

    final oldest =
        cached.map((p) => p.cachedAt).reduce((a, b) => a.isBefore(b) ? a : b);

    if (DateTime.now().difference(oldest) > _cacheValidity) return null;

    return cached;
  }

  @override
  Future<PokemonDetailIsarModel?> getCachedPokemonDetail(int id) async {
    final cached = await _isar.pokemonDetailIsarModels.get(id);
    if (cached == null) return null;

    if (DateTime.now().difference(cached.cachedAt) > _cacheValidity) {
      return null;
    }

    return cached;
  }

  @override
  Future<void> cachePokemonList(List<PokemonIsarModel> pokemon) async {
    await _isar.writeTxn(() async {
      await _isar.pokemonIsarModels.putAll(pokemon);
    });
  }

  @override
  Future<void> cachePokemonDetail(PokemonDetailIsarModel detail) async {
    await _isar.writeTxn(() async {
      await _isar.pokemonDetailIsarModels.put(detail);
    });
  }

  @override
  Future<bool> hasCachedData() async {
    final count = await _isar.pokemonIsarModels.count();
    return count > 0;
  }
}
