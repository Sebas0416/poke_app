import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_app/core/router/app_router.dart';
import 'package:poke_app/features/pokemon/domain/entities/pokemon_entity.dart';
import 'package:poke_app/features/pokemon/presentation/providers/pokemon_provider.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_card.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_empty_state.dart';

class PokemonCarousel extends ConsumerStatefulWidget {
  final bool isLoadingMore;

  const PokemonCarousel({
    super.key,
    required this.isLoadingMore,
  });

  @override
  ConsumerState<PokemonCarousel> createState() => _PokemonCarouselState();
}

class _PokemonCarouselState extends ConsumerState<PokemonCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }

    final pokemonState = ref.read(pokemonListProvider);
    if (pokemonState is PokemonListLoaded) {
      final total = pokemonState.pokemon.length;
      if (page >= total - 3 && pokemonState.hasMore) {
        ref.read(pokemonListProvider.notifier).loadMore();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = ref.watch(filteredPokemonProvider);

    if (pokemon.isEmpty) return const PokemonEmptyState();

    return Column(
      children: [
        const SizedBox(height: 8),
        Expanded(child: _buildPageView(pokemon)),
        const SizedBox(height: 16),
        _buildIndicator(pokemon),
        if (widget.isLoadingMore) _buildLoadingMore(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPageView(List<PokemonEntity> pokemon) {
    return PageView.builder(
      key: const PageStorageKey('pokemon_carousel'),
      controller: _pageController,
      itemCount: pokemon.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 0;
            if (_pageController.position.haveDimensions) {
              value = index - (_pageController.page ?? 0);
              value = (value * 0.08).clamp(-1, 1);
            }
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(value * 2.5),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: PokemonCard(
            pokemon: pokemon[index],
            isCenter: index == _currentPage,
            onTap: () => context.push(
              AppRoutes.detailPath(pokemon[index].id),
              extra: pokemon[index].name,
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicator(List<PokemonEntity> pokemon) {
    return Text(
      '${_currentPage + 1} / ${pokemon.length}',
      style: TextStyle(
        color: Colors.white.withAlpha(180),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: 120,
        child: LinearProgressIndicator(
          backgroundColor: Colors.white.withAlpha(30),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
