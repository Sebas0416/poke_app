import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_app/features/pokemon/presentation/providers/pokemon_provider.dart';

class SearchBarWidget extends ConsumerWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextFormField(
        onChanged: (value) =>
            ref.read(searchQueryProvider.notifier).state = value,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar Pokémon...',
          hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withAlpha(150),
          ),
          filled: true,
          fillColor: Colors.white.withAlpha(20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE94560),
              width: 2,
            ),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
