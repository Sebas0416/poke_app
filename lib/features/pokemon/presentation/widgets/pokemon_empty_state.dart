import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PokemonEmptyState extends StatelessWidget {
  const PokemonEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Lottie.asset(
                'assets/animations/Snorlax.json',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No se encontraron Pokémon',
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro filtro o búsqueda',
            style: TextStyle(
              color: Colors.white.withAlpha(80),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
