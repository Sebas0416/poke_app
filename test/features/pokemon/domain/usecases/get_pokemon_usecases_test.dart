import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_detail_entity.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_entity.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_stat_entity.dart';
import 'package:poke_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:poke_app/features/pokemon/domain/usecases/get_pokemon_usecases.dart';

import 'get_pokemon_usecases_test.mocks.dart';

@GenerateMocks([PokemonRepository])
void main() {
  late GetPokemonListUseCase getListUseCase;
  late GetPokemonDetailUseCase getDetailUseCase;
  late MockPokemonRepository mockRepository;

  setUp(() {
    mockRepository = MockPokemonRepository();
    getListUseCase = GetPokemonListUseCase(mockRepository);
    getDetailUseCase = GetPokemonDetailUseCase(mockRepository);
  });

  final tPokemonList = [
    const PokemonEntity(id: 1, name: 'bulbasaur', types: ['grass', 'poison']),
    const PokemonEntity(id: 2, name: 'ivysaur', types: ['grass', 'poison']),
    const PokemonEntity(id: 3, name: 'venusaur', types: ['grass', 'poison']),
  ];

  final tPokemonDetail = PokemonDetailEntity(
    id: 1,
    name: 'bulbasaur',
    types: const ['grass', 'poison'],
    height: 7,
    weight: 69,
    baseExperience: 64,
    stats: const [
      PokemonStatEntity(name: 'hp', baseStat: 45),
      PokemonStatEntity(name: 'attack', baseStat: 49),
    ],
    abilities: const ['overgrow', 'chlorophyll'],
  );

  group('GetPokemonListUseCase', () {
    test('debe retornar lista de pokemon cuando el repositorio tiene éxito',
        () async {
      when(mockRepository.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => Right(tPokemonList));

      final result = await getListUseCase();

      expect(result, Right(tPokemonList));
      verify(mockRepository.getPokemonList(
        limit: 20,
        offset: 0,
        forceRefresh: false,
      ));
    });

    test('debe retornar NetworkFailure cuando no hay conexión', () async {
      const failure = NetworkFailure('Sin conexión');
      when(mockRepository.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => const Left(failure));

      final result = await getListUseCase();

      expect(result, const Left(failure));
    });

    test('debe pasar los parámetros de paginación correctamente', () async {
      when(mockRepository.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => Right(tPokemonList));

      await getListUseCase(limit: 10, offset: 20);

      verify(mockRepository.getPokemonList(
        limit: 10,
        offset: 20,
        forceRefresh: false,
      ));
    });
  });

  group('GetPokemonDetailUseCase', () {
    test('debe retornar detalle del pokemon cuando el repositorio tiene éxito',
        () async {
      when(mockRepository.getPokemonDetail(1))
          .thenAnswer((_) async => Right(tPokemonDetail));

      final result = await getDetailUseCase(1);

      expect(result, Right(tPokemonDetail));
      verify(mockRepository.getPokemonDetail(1));
    });

    test('debe retornar ServerFailure cuando el servidor falla', () async {
      const failure = ServerFailure(message: 'Error del servidor');
      when(mockRepository.getPokemonDetail(1))
          .thenAnswer((_) async => const Left(failure));

      final result = await getDetailUseCase(1);

      expect(result, const Left(failure));
    });
  });
}
