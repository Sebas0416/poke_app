import 'package:dartz/dartz.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_detail_entity.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_entity.dart';

abstract class PokemonRepository {
  Future<Either<Failure, List<PokemonEntity>>> getPokemonList({
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  });

  Future<Either<Failure, PokemonDetailEntity>> getPokemonDetail(int id);

  Future<bool> hasCachedData();
}
