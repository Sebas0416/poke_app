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

abstract class PokemonListState {}

class PokemonListInitial extends PokemonListState {}

class PokemonListLoading extends PokemonListState {}

class PokemonListLoaded extends PokemonListState {
  final List<PokemonEntity> pokemon;
  final bool isOffline;
  final bool hasMore;
  final bool isLoadingMore;
  PokemonListLoaded(this.pokemon,
      {this.isOffline = false,
      this.hasMore = true,
      this.isLoadingMore = false});
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

  static const int _pageSize = 10;
  int _offset = 0;
  bool _hasMore = true;
  List<PokemonEntity> _allPokemon = [];
  bool _isLoadingMore = false;

  PokemonListNotifier(this._ref) : super(PokemonListInitial()) {
    loadPokemon();
  }

  Future<void> loadPokemon({bool forceRefresh = false}) async {
    if (state is PokemonListLoading) return;

    if (forceRefresh) {
      _offset = 0;
      _hasMore = true;
      _allPokemon = [];
    }

    state = PokemonListLoading();

    final isConnected = await _ref.read(isConnectedProvider.future);
    final useCase = await _ref.read(getPokemonListUseCaseProvider.future);
    final result = await useCase.call(
      limit: _pageSize,
      offset: _offset,
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) => state = PokemonListError(failure.message),
      (pokemon) {
        _allPokemon = [..._allPokemon, ...pokemon];
        _offset += _pageSize;
        _hasMore = pokemon.length == _pageSize;
        state = PokemonListLoaded(
          _allPokemon,
          isOffline: !isConnected,
          hasMore: _hasMore,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    if (_isLoadingMore) return;
    if (state is PokemonListLoading) return;
    _isLoadingMore = true;
    if (state is PokemonListLoaded) {
      state = PokemonListLoaded(
        _allPokemon,
        isOffline: false,
        hasMore: _hasMore,
        isLoadingMore: true,
      );
    }
    final isConnected = await _ref.read(isConnectedProvider.future);
    final useCase = await _ref.read(getPokemonListUseCaseProvider.future);
    final result = await useCase.call(
      limit: _pageSize,
      offset: _offset,
    );

    result.fold(
      (failure) {
        _isLoadingMore = false;
        state = PokemonListError(failure.message);
      },
      (pokemon) {
        _allPokemon = [..._allPokemon, ...pokemon];
        _offset += _pageSize;
        _hasMore = pokemon.length == _pageSize;
        _isLoadingMore = false;
        state = PokemonListLoaded(
          _allPokemon,
          isOffline: !isConnected,
          hasMore: _hasMore,
          isLoadingMore: false,
        );
      },
    );
    _isLoadingMore = false;
  }

  Future<void> refresh() => loadPokemon(forceRefresh: true);
}

abstract class PokemonDetailState {}

class PokemonDetailInitial extends PokemonDetailState {}

class PokemonDetailLoading extends PokemonDetailState {}

class PokemonDetailLoaded extends PokemonDetailState {
  final PokemonDetailEntity pokemon;
  PokemonDetailLoaded(this.pokemon);
}

class PokemonDetailError extends PokemonDetailState {
  final String message;
  PokemonDetailError(this.message);
}

final pokemonDetailProvider = StateNotifierProvider.family<
    PokemonDetailNotifier, PokemonDetailState, int>(
  (ref, pokemonId) => PokemonDetailNotifier(ref, pokemonId),
);

class PokemonDetailNotifier extends StateNotifier<PokemonDetailState> {
  final Ref _ref;
  final int _pokemonId;

  PokemonDetailNotifier(this._ref, this._pokemonId)
      : super(PokemonDetailInitial()) {
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

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTypeProvider = StateProvider<String?>((ref) => null);

final filteredPokemonProvider = Provider<List<PokemonEntity>>((ref) {
  final pokemonState = ref.watch(pokemonListProvider);
  if (pokemonState is! PokemonListLoaded) return [];

  final query = ref.watch(searchQueryProvider).toLowerCase();
  final selectedType = ref.watch(selectedTypeProvider);

  return pokemonState.pokemon.where((p) {
    final matchesQuery = query.isEmpty ||
        p.name.toLowerCase().contains(query) ||
        p.id.toString() == query;
    final matchesType = selectedType == null || p.types.contains(selectedType);
    return matchesQuery && matchesType;
  }).toList();
});
