import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:poke_app/core/errors/failures.dart';
import 'package:poke_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:poke_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:poke_app/features/pokemon/data/models/pokemo_detail_model.dart';
import 'package:poke_app/features/pokemon/data/models/pokemon_isar_model.dart';
import 'package:poke_app/features/pokemon/data/models/pokemon_model.dart';
import 'package:poke_app/features/pokemon/data/repositories/pokemon_repository_impl.dart';

import 'pokemon_repository_impl_test.mocks.dart';

@GenerateMocks([PokemonRemoteDatasource, PokemonLocalDatasource])
void main() {
  late PokemonRepositoryImpl repository;
  late MockPokemonRemoteDatasource mockRemote;
  late MockPokemonLocalDatasource mockLocal;
  bool isConnected = true;

  setUp(() {
    mockRemote = MockPokemonRemoteDatasource();
    mockLocal = MockPokemonLocalDatasource();
    isConnected = true;
    repository = PokemonRepositoryImpl(
      remote: mockRemote,
      local: mockLocal,
      isConnected: () => isConnected,
    );
  });

  final tPokemonModels = [
    const PokemonModel(id: 1, name: 'bulbasaur', types: ['grass']),
    const PokemonModel(id: 2, name: 'ivysaur', types: ['grass']),
  ];

  final tIsarModels = tPokemonModels.map((m) {
    return PokemonIsarModel()
      ..id = m.id
      ..name = m.name
      ..types = m.types
      ..cachedAt = DateTime.now();
  }).toList();

  group('getPokemonList', () {
    test('debe retornar datos del caché cuando existen y son válidos',
        () async {
      when(mockLocal.getCachedPokemonList())
          .thenAnswer((_) async => tIsarModels);

      final result = await repository.getPokemonList();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('debería ser Right'),
        (list) => expect(list.length, 2),
      );
      verifyNever(mockRemote.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      ));
    });

    test('debe ir a la red cuando el caché está vacío', () async {
      when(mockLocal.getCachedPokemonList()).thenAnswer((_) async => null);
      when(mockRemote.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => tPokemonModels);
      when(mockLocal.cachePokemonList(any)).thenAnswer((_) async {});

      final result = await repository.getPokemonList();

      expect(result.isRight(), true);
      verify(mockRemote.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      ));
    });

    test('debe retornar NetworkFailure cuando no hay conexión ni caché',
        () async {
      isConnected = false;
      when(mockLocal.getCachedPokemonList()).thenAnswer((_) async => null);

      final result = await repository.getPokemonList();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('debería ser Left'),
      );
    });

    test('debe ir a la red cuando forceRefresh es true aunque haya caché',
        () async {
      when(mockLocal.getCachedPokemonList())
          .thenAnswer((_) async => tIsarModels);
      when(mockRemote.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => tPokemonModels);
      when(mockLocal.cachePokemonList(any)).thenAnswer((_) async {});

      final result = await repository.getPokemonList(forceRefresh: true);

      expect(result.isRight(), true);
      verify(mockRemote.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      ));
    });

    test('debe retornar ServerFailure cuando la red falla', () async {
      when(mockLocal.getCachedPokemonList()).thenAnswer((_) async => null);
      when(mockRemote.getPokemonList(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenThrow(Exception('Error de servidor'));

      final result = await repository.getPokemonList();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('debería ser Left'),
      );
    });
  });

  group('getPokemonDetail', () {
    final tDetailModel = PokemonDetailModel.fromJson({
      'id': 1,
      'name': 'bulbasaur',
      'types': [
        {
          'type': {'name': 'grass'}
        },
      ],
      'height': 7,
      'weight': 69,
      'base_experience': 64,
      'stats': [
        {
          'stat': {'name': 'hp'},
          'base_stat': 45
        },
      ],
      'abilities': [
        {
          'ability': {'name': 'overgrow'}
        },
      ],
    });

    test('debe retornar detalle del caché cuando existe', () async {
      final isarDetail = PokemonDetailIsarModel()
        ..id = 1
        ..name = 'bulbasaur'
        ..types = ['grass']
        ..height = 7
        ..weight = 69
        ..baseExperience = 64
        ..statNames = ['hp']
        ..statValues = [45]
        ..abilities = ['overgrow']
        ..cachedAt = DateTime.now();

      when(mockLocal.getCachedPokemonDetail(1))
          .thenAnswer((_) async => isarDetail);

      final result = await repository.getPokemonDetail(1);

      expect(result.isRight(), true);
      verifyNever(mockRemote.getPokemonDetail(any));
    });

    test('debe ir a la red cuando no hay caché', () async {
      when(mockLocal.getCachedPokemonDetail(1)).thenAnswer((_) async => null);
      when(mockRemote.getPokemonDetail(1))
          .thenAnswer((_) async => tDetailModel);
      when(mockLocal.cachePokemonDetail(any)).thenAnswer((_) async {});

      final result = await repository.getPokemonDetail(1);

      expect(result.isRight(), true);
      verify(mockRemote.getPokemonDetail(1));
    });

    test('debe retornar NetworkFailure cuando no hay conexión ni caché',
        () async {
      isConnected = false;
      when(mockLocal.getCachedPokemonDetail(1)).thenAnswer((_) async => null);

      final result = await repository.getPokemonDetail(1);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('debería ser Left'),
      );
    });
  });
}
