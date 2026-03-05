import 'package:flutter/material.dart';

class AnimatedPokeball extends StatefulWidget {
  final double size;

  const AnimatedPokeball({super.key, this.size = 100});

  @override
  State<AnimatedPokeball> createState() => _AnimatedPokeballState();
}

class _AnimatedPokeballState extends State<AnimatedPokeball>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE94560), Color(0xFFFF6B6B)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE94560).withAlpha(128),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.catching_pokemon,
          size: widget.size * 0.56,
          color: Colors.white,
        ),
      ),
    );
  }
}
