import 'package:dartz/dartz.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:poke_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:poke_app/features/pokemon/data/models/pokemon_isar_model.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_detail_entity.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_entity.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_stat_entity.dart';
import 'package:poke_app/features/pokemon/domain/repositories/pokemon_repository.dart';

/// Implements offline-first strategy:
/// 1. Try cache first
/// 2. If cache empty or expired fetch from network
/// 3. If offline and no cache return failure
class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDatasource _remote;
  final PokemonLocalDatasource _local;
  final bool Function() _isConnected;

  const PokemonRepositoryImpl({
    required PokemonRemoteDatasource remote,
    required PokemonLocalDatasource local,
    required bool Function() isConnected,
  })  : _remote = remote,
        _local = local,
        _isConnected = isConnected;

  @override
  Future<Either<Failure, List<PokemonEntity>>> getPokemonList({
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && offset == 0) {
      final cached = await _local.getCachedPokemonList();
      if (cached != null && cached.isNotEmpty) {
        return Right(cached.map(_isarToEntity).toList());
      }
    }

    if (_isConnected()) {
      try {
        final models = await _remote.getPokemonList(
          limit: limit,
          offset: offset,
        );
        final isarModels = models.map((m) {
          return PokemonIsarModel()
            ..id = m.id
            ..name = m.name
            ..types = m.types
            ..cachedAt = DateTime.now();
        }).toList();
        await _local.cachePokemonList(isarModels);
        return Right(models);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    }

    return const Left(NetworkFailure('Sin conexión y sin datos guardados'));
  }

  @override
  Future<Either<Failure, PokemonDetailEntity>> getPokemonDetail(int id) async {
    final cached = await _local.getCachedPokemonDetail(id);
    if (cached != null) {
      return Right(_isarDetailToEntity(cached));
    }

    if (_isConnected()) {
      try {
        final model = await _remote.getPokemonDetail(id);
        final isarModel = PokemonDetailIsarModel()
          ..id = model.id
          ..name = model.name
          ..types = model.types
          ..height = model.height
          ..weight = model.weight
          ..baseExperience = model.baseExperience
          ..statNames = model.stats.map((s) => s.name).toList()
          ..statValues = model.stats.map((s) => s.baseStat).toList()
          ..abilities = model.abilities
          ..cachedAt = DateTime.now();
        await _local.cachePokemonDetail(isarModel);
        return Right(model);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    }

    return const Left(NetworkFailure('Sin conexión para obtener el detalle'));
  }

  @override
  Future<bool> hasCachedData() => _local.hasCachedData();

  PokemonEntity _isarToEntity(PokemonIsarModel m) => PokemonEntity(
        id: m.id,
        name: m.name,
        types: m.types,
      );

  PokemonDetailEntity _isarDetailToEntity(PokemonDetailIsarModel m) =>
      PokemonDetailEntity(
        id: m.id,
        name: m.name,
        types: m.types,
        height: m.height,
        weight: m.weight,
        baseExperience: m.baseExperience,
        stats: List.generate(
          m.statNames.length,
          (i) => PokemonStatEntity(
            name: m.statNames[i],
            baseStat: m.statValues[i],
          ),
        ),
        abilities: m.abilities,
      );
}
