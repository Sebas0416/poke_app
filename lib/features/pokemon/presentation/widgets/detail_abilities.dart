import 'package:flutter/material.dart';

class DetailAbilities extends StatelessWidget {
  final List<String> abilities;
  final Color typeColor;

  const DetailAbilities({
    super.key,
    required this.abilities,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habilidades',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: abilities
                .map((a) => _AbilityChip(
                      ability: a,
                      typeColor: typeColor,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AbilityChip extends StatelessWidget {
  final String ability;
  final Color typeColor;

  const _AbilityChip({required this.ability, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: typeColor.withAlpha(60),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: typeColor.withAlpha(120)),
      ),
      child: Text(
        ability.replaceAll('-', ' ').toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
