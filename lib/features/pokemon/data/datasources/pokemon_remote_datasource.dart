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
      //return results.map((json) => PokemonModel.fromListJson(json)).toList();
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

      final details = await Future.wait(
        results.map((json) async {
          final urlParts = (json['url'] as String).split('/');
          final id = int.parse(urlParts[urlParts.length - 2]);
          try {
            final detail = await _dio.get('/pokemon/$id');
            return PokemonModel.fromDetailJson(detail.data);
          } catch (_) {
            return PokemonModel.fromListJson(json);
          }
        }),
      );

      return details;
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
