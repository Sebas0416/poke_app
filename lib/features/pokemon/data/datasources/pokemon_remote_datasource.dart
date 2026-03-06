import 'package:dio/dio.dart';
import 'package:poke_app/features/pokemon/data/models/pokemo_detail_model.dart';
import 'package:poke_app/features/pokemon/data/models/pokemon_model.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_evolution_entity.dart';

abstract class PokemonRemoteDatasource {
  Future<List<PokemonModel>> getPokemonList({int limit, int offset});
  Future<PokemonDetailModel> getPokemonDetail(int id);
  Future<List<PokemonEvolutionEntity>> getPokemonEvolutions(int pokemonId);
}

class PokemonRemoteDatasourceImpl implements PokemonRemoteDatasource {
  final Dio _dio;

  const PokemonRemoteDatasourceImpl(this._dio);
  static const int _concurrency = 5;

  @override
  Future<List<PokemonModel>> getPokemonList({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/pokemon',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final results = response.data['results'] as List;
      final ids = results.map((json) {
        final urlParts = (json['url'] as String).split('/');
        return int.parse(urlParts[urlParts.length - 2]);
      }).toList();
      final allModels = <PokemonModel>[];
      for (var i = 0; i < ids.length; i += _concurrency) {
        final batchIds = ids.skip(i).take(_concurrency).toList();
        final batch = await Future.wait(
          batchIds.map((id) async {
            try {
              final detail = await _dio.get('/pokemon/$id');
              return PokemonModel.fromDetailJson(detail.data);
            } catch (_) {
              return PokemonModel(
                id: id,
                name: results[ids.indexOf(id)]['name'] as String,
                types: const [],
              );
            }
          }),
        );
        allModels.addAll(batch);
      }
      return allModels;
    } on DioException catch (e) {
      throw Exception('Error fetching pokemon list: ${e.message}');
    }
  }

  @override
  Future<PokemonDetailModel> getPokemonDetail(int id) async {
    try {
      final response = await _dio.get('/pokemon/$id');
      return PokemonDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error fetching pokemon detail: ${e.message}');
    }
  }

  @override
  Future<List<PokemonEvolutionEntity>> getPokemonEvolutions(
      int pokemonId) async {
    try {
      final speciesRes = await _dio.get('/pokemon-species/$pokemonId');
      final evolutionUrl = speciesRes.data['evolution_chain']['url'] as String;

      final evoRes = await _dio.get(evolutionUrl);
      final chain = evoRes.data['chain'];

      final evolutions = <PokemonEvolutionEntity>[];
      _parseChain(chain, evolutions);
      return evolutions;
    } on DioException catch (e) {
      throw Exception('Error fetching evolutions: ${e.message}');
    }
  }

  void _parseChain(
    Map<String, dynamic> chain,
    List<PokemonEvolutionEntity> result,
  ) {
    final name = chain['species']['name'] as String;
    final url = chain['species']['url'] as String;
    final urlParts = url.split('/');
    final id = int.parse(urlParts[urlParts.length - 2]);

    result.add(PokemonEvolutionEntity(id: id, name: name));

    final evolvesTo = chain['evolves_to'] as List;
    for (final next in evolvesTo) {
      _parseChain(next, result);
    }
  }
}
