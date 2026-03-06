import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_flutter.dart';

class PokemonParticles extends StatelessWidget {
  final Color color;

  const PokemonParticles({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircularParticle(
      awayRadius: 120,
      numberOfParticles: 30,
      speedOfParticles: 1.2,
      height: 300,
      width: 300,
      particleColor: color,
      awayAnimationDuration: const Duration(milliseconds: 600),
      maxParticleSize: 8,
      isRandSize: true,
      isRandomColor: false,
      awayAnimationCurve: Curves.easeInOutBack,
    );
  }
}
