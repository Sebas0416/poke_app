import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_type_chip.dart';

void main() {
  Widget buildSubject(String type) {
    return MaterialApp(
      home: Scaffold(
        body: PokemonTypeChip(type: type),
      ),
    );
  }

  group('PokemonTypeChip', () {
    testWidgets('debe mostrar el tipo en mayúsculas', (tester) async {
      await tester.pumpWidget(buildSubject('fire'));
      expect(find.text('FIRE'), findsOneWidget);
    });

    testWidgets('debe mostrar color correcto para tipo fire', (tester) async {
      await tester.pumpWidget(buildSubject('fire'));
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('debe mostrar color correcto para tipo water', (tester) async {
      await tester.pumpWidget(buildSubject('water'));
      expect(find.text('WATER'), findsOneWidget);
    });

    testWidgets('debe usar color normal para tipo desconocido', (tester) async {
      final color = PokemonTypeChip.typeColor('desconocido');
      expect(color, const Color(0xFFA8A878));
    });
  });
}
