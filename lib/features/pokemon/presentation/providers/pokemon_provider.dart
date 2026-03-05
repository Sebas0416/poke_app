import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poke_app/core/network/connectivity_service.dart';
import 'package:poke_app/core/network/dio_client.dart';
import 'package:poke_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:poke_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:poke_app/features/pokemon/data/models/pokemon_isar_model.dart';
import 'package:poke_app/features/pokemon/data/repositories/pokemon_repository_impl.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_detail_entity.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_entity.dart';
import 'package:poke_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:poke_app/features/pokemon/domain/usecases/get_pokemon_usecases.dart';

// --- Infrastructure ---

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [PokemonIsarModelSchema, PokemonDetailIsarModelSchema],
    directory: dir.path,
  );
});

final pokemonLocalDatasourceProvider =
    FutureProvider<PokemonLocalDatasource>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return PokemonLocalDatasourceImpl(isar);
});

final pokemonRemoteDatasourceProvider =
    Provider<PokemonRemoteDatasource>((ref) {
  return PokemonRemoteDatasourceImpl(ref.watch(dioClientProvider));
});

final pokemonRepositoryProvider =
    FutureProvider<PokemonRepository>((ref) async {
  final local = await ref.watch(pokemonLocalDatasourceProvider.future);
  final remote = ref.watch(pokemonRemoteDatasourceProvider);
  final isConnected = await ref.watch(isConnectedProvider.future);

  return PokemonRepositoryImpl(
    remote: remote,
    local: local,
    isConnected: () => isConnected,
  );
});

final getPokemonListUseCaseProvider =
    FutureProvider<GetPokemonListUseCase>((ref) async {
  final repo = await ref.watch(pokemonRepositoryProvider.future);
  return GetPokemonListUseCase(repo);
});

final getPokemonDetailUseCaseProvider =
    FutureProvider<GetPokemonDetailUseCase>((ref) async {
  final repo = await ref.watch(pokemonRepositoryProvider.future);
  return GetPokemonDetailUseCase(repo);
});

// --- Pokemon List State ---

abstract class PokemonListState {}

class PokemonListInitial extends PokemonListState {}

class PokemonListLoading extends PokemonListState {}

class PokemonListLoaded extends PokemonListState {
  final List<PokemonEntity> pokemon;
  final bool isOffline;
  PokemonListLoaded(this.pokemon, {this.isOffline = false});
}

class PokemonListError extends PokemonListState {
  final String message;
  PokemonListError(this.message);
}

final pokemonListProvider =
    StateNotifierProvider<PokemonListNotifier, PokemonListState>(
  (ref) => PokemonListNotifier(ref),
);

class PokemonListNotifier extends StateNotifier<PokemonListState> {
  final Ref _ref;

  PokemonListNotifier(this._ref) : super(PokemonListInitial()) {
    loadPokemon();
  }

  Future<void> loadPokemon({bool forceRefresh = false}) async {
    state = PokemonListLoading();

    final isConnected = await _ref.read(isConnectedProvider.future);
    final useCase = await _ref.read(getPokemonListUseCaseProvider.future);
    final result = await useCase.call(forceRefresh: forceRefresh);

    result.fold(
      (failure) => state = PokemonListError(failure.message),
      (pokemon) => state = PokemonListLoaded(
        pokemon,
        isOffline: !isConnected,
      ),
    );
  }

  Future<void> refresh() => loadPokemon(forceRefresh: true);
}



abstract class PokemonDetailState {}

class PokemonDetailInitial {}

class PokemonDetailLoading extends PokemonDetailState {}

class PokemonDetailLoaded extends PokemonDetailState {
  final PokemonDetailEntity pokemon;
  PokemonDetailLoaded(this.pokemon);
}

class PokemonDetailError extends PokemonDetailState {
  final String message;
  PokemonDetailError(this.message);
}

final pokemonDetailProvider = StateNotifierProvider.family
    PokemonDetailNotifier, PokemonDetailState, int>(
  (ref, id) => PokemonDetailNotifier(ref, id),
);

class PokemonDetailNotifier extends StateNotifier<PokemonDetailState> {
  final Ref _ref;
  final int _pokemonId;

  PokemonDetailNotifier(this._ref, this._pokemonId) : super(PokemonDetailInitial()) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    state = PokemonDetailLoading();
    final useCase = await _ref.read(getPokemonDetailUseCaseProvider.future);
    final result = await useCase.call(_pokemonId);

    result.fold(
      (failure) => state = PokemonDetailError(failure.message),
      (pokemon) => state = PokemonDetailLoaded(pokemon),
    );
  }
}