import 'package:flutter/material.dart';

class PokemonStatBar extends StatefulWidget {
  final String name;
  final int value;
  final Color color;

  const PokemonStatBar({
    super.key,
    required this.name,
    required this.value,
    required this.color,
  });

  @override
  State<PokemonStatBar> createState() => _PokemonStatBarState();
}

class _PokemonStatBarState extends State<PokemonStatBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _statLabel {
    const labels = {
      'hp': 'HP',
      'attack': 'ATK',
      'defense': 'DEF',
      'special-attack': 'SP.ATK',
      'special-defense': 'SP.DEF',
      'speed': 'SPD',
    };
    return labels[widget.name] ?? widget.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              _statLabel,
              style: TextStyle(
                color: Colors.white.withAlpha(153),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              widget.value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return LinearProgressIndicator(
                    value: (widget.value / 255) * _animation.value,
                    backgroundColor: Colors.white.withAlpha(26),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    minHeight: 8,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
