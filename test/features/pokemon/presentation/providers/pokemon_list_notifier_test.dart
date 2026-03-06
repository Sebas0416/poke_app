import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/core/network/connectivity_service.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_detail_entity.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_entity.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_stat_entity.dart';
import 'package:poke_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:poke_app/features/pokemon/domain/usecases/get_pokemon_usecases.dart';
import 'package:poke_app/features/pokemon/presentation/providers/pokemon_provider.dart';

import 'pokemon_list_notifier_test.mocks.dart';

@GenerateMocks([PokemonRepository])
void main() {
  late MockPokemonRepository mockRepository;

  final tPokemonList = [
    const PokemonEntity(id: 1, name: 'bulbasaur', types: ['grass']),
    const PokemonEntity(id: 2, name: 'charmander', types: ['fire']),
    const PokemonEntity(id: 3, name: 'squirtle', types: ['water']),
  ];

  ProviderContainer makeContainer({bool isOnline = true}) {
    return ProviderContainer(
      overrides: [
        pokemonRepositoryProvider.overrideWith(
          (ref) async => mockRepository,
        ),
        getPokemonListUseCaseProvider.overrideWith(
          (ref) async => GetPokemonListUseCase(mockRepository),
        ),
        getPokemonDetailUseCaseProvider.overrideWith(
          (ref) async => GetPokemonDetailUseCase(mockRepository),
        ),
        isConnectedProvider.overrideWith(
          (ref) async => isOnline,
        ),
      ],
    );
  }

  Future<PokemonListState> waitForState(ProviderContainer container) async {
    PokemonListState state = container.read(pokemonListProvider);
    if (state is PokemonListLoading || state is PokemonListInitial) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        state = container.read(pokemonListProvider);
        return state is PokemonListLoading || state is PokemonListInitial;
      });
    }
    return state;
  }

  setUp(() {
    mockRepository = MockPokemonRepository();
  });

  group('PokemonListNotifier', () {
    test('debe cambiar a PokemonListLoaded después de cargar', () async {
      when(mockRepository.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => Right(tPokemonList));

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(pokemonListProvider);
      final state = await waitForState(container);

      expect(state, isA<PokemonListLoaded>());
      expect((state as PokemonListLoaded).pokemon.length, 3);
      expect(state.pokemon.first.name, 'bulbasaur');
    });

    test('debe cambiar a PokemonListError cuando falla la red', () async {
      when(mockRepository.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer(
        (_) async => const Left(NetworkFailure('Sin conexión')),
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(pokemonListProvider);
      final state = await waitForState(container);

      expect(state, isA<PokemonListError>());
      expect((state as PokemonListError).message, 'Sin conexión');
    });

    test('refresh debe recargar la lista completa', () async {
      when(mockRepository.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => Right(tPokemonList));

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(pokemonListProvider);
      await waitForState(container);

      await container.read(pokemonListProvider.notifier).refresh();
      final state = await waitForState(container);

      expect(state, isA<PokemonListLoaded>());
      verify(mockRepository.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
        forceRefresh: anyNamed('forceRefresh'),
      )).called(greaterThanOrEqualTo(2));
    });

    test('isOffline debe ser true cuando no hay conexión', () async {
      when(mockRepository.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => Right(tPokemonList));

      final container = makeContainer(isOnline: false);
      addTearDown(container.dispose);

      container.read(pokemonListProvider);
      final state = await waitForState(container);

      expect(state, isA<PokemonListLoaded>());
      expect((state as PokemonListLoaded).isOffline, true);
    });
  });

  group('PokemonDetailNotifier', () {
    final tDetail = PokemonDetailEntity(
      id: 1,
      name: 'bulbasaur',
      types: const ['grass'],
      height: 7,
      weight: 69,
      baseExperience: 64,
      stats: const [PokemonStatEntity(name: 'hp', baseStat: 45)],
      abilities: const ['overgrow'],
    );

    Future<PokemonDetailState> waitForDetailState(
      ProviderContainer container,
      int id,
    ) async {
      PokemonDetailState state = container.read(pokemonDetailProvider(id));
      if (state is PokemonDetailLoading || state is PokemonDetailInitial) {
        await Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 50));
          state = container.read(pokemonDetailProvider(id));
          return state is PokemonDetailLoading || state is PokemonDetailInitial;
        });
      }
      return state;
    }

    test('debe cargar el detalle correctamente', () async {
      when(mockRepository.getPokemonDetail(1))
          .thenAnswer((_) async => Right(tDetail));

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(pokemonDetailProvider(1));
      final state = await waitForDetailState(container, 1);

      expect(state, isA<PokemonDetailLoaded>());
      expect((state as PokemonDetailLoaded).pokemon.name, 'bulbasaur');
    });

    test('debe retornar error cuando falla la carga del detalle', () async {
      when(mockRepository.getPokemonDetail(1)).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Error del servidor')),
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(pokemonDetailProvider(1));
      final state = await waitForDetailState(container, 1);

      expect(state, isA<PokemonDetailError>());
      expect((state as PokemonDetailError).message, 'Error del servidor');
    });
  });
}
