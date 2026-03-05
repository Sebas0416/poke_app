import 'package:dartz/dartz.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_detail_entity.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_entity.dart';
import 'package:poke_app/features/pokemon/domain/repositories/pokemon_repository.dart';

class GetPokemonListUseCase {
  final PokemonRepository _repository;

  const GetPokemonListUseCase(this._repository);

  Future<Either<Failure, List<PokemonEntity>>> call({
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) {
    return _repository.getPokemonList(
      limit: limit,
      offset: offset,
      forceRefresh: forceRefresh,
    );
  }
}

class GetPokemonDetailUseCase {
  final PokemonRepository _repository;

  const GetPokemonDetailUseCase(this._repository);

  Future<Either<Failure, PokemonDetailEntity>> call(int id) {
    return _repository.getPokemonDetail(id);
  }
}
