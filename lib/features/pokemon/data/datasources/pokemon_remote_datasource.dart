import 'package:dio/dio.dart';
import 'package:poke_app/features/pokemon/data/models/pokemo_detail_model.dart';
import 'package:poke_app/features/pokemon/data/models/pokemon_model.dart';

abstract class PokemonRemoteDatasource {
  Future<List<PokemonModel>> getPokemonList({int limit, int offset});
  Future<PokemonDetailModel> getPokemonDetail(int id);
}

class PokemonRemoteDatasourceImpl implements PokemonRemoteDatasource {
  final Dio _dio;

  const PokemonRemoteDatasourceImpl(this._dio);

  @override
  Future<List<PokemonModel>> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/pokemon',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final results = response.data['results'] as List;
      return results.map((json) => PokemonModel.fromListJson(json)).toList();
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
}
