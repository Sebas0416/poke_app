import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_app/core/network/connectivity_service.dart';
import 'package:poke_app/core/router/app_router.dart';
import 'package:poke_app/core/widgets/gradient_background.dart';
import 'package:poke_app/features/pokemon/presentation/providers/pokemon_provider.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/offline_banner.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_card.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/refresh_button.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _showRefreshButton = false;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
    _pageController.addListener(() {
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
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pokemonState = ref.watch(pokemonListProvider);
    final connectivityAsync = ref.watch(connectivityProvider);

    ref.listen(connectivityProvider, (previous, next) {
      next.whenData((isOnline) {
        if (_wasOffline && isOnline) {
          setState(() => _showRefreshButton = true);
        }
        _wasOffline = !isOnline;
      });
    });

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Poke App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                          ),
                          onPressed: () => context.push(AppRoutes.settings),
                        ),
                      ],
                    ),
                  ),
                  connectivityAsync.when(
                    data: (isOnline) => isOnline
                        ? const SizedBox.shrink()
                        : const OfflineBanner(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: switch (pokemonState) {
                      PokemonListInitial() ||
                      PokemonListLoading() =>
                        _buildLoading(),
                      PokemonListError(:final message) => _buildError(message),
                      PokemonListLoaded() => _buildCarousel(pokemonState),
                      PokemonListState() => throw UnimplementedError(),
                    },
                  ),
                ],
              ),
              if (_showRefreshButton)
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: RefreshButton(
                      onTap: () {
                        setState(() => _showRefreshButton = false);
                        ref.read(pokemonListProvider.notifier).refresh();
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(PokemonListLoaded state) {
    final pokemon = state.pokemon;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: PageView.builder(
            key: const PageStorageKey('pokemon_carousel'),
            controller: _pageController,
            itemCount: pokemon.length,
            itemBuilder: (context, index) {
              return PokemonCard(
                pokemon: pokemon[index],
                isCenter: index == _currentPage,
                onTap: () => context.push(
                  AppRoutes.detailPath(pokemon[index].id),
                  extra: pokemon[index].name,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${_currentPage + 1} / ${pokemon.length}',
          style: TextStyle(
            color: Colors.white.withAlpha(180),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (state.isLoadingMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withAlpha(30),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFE94560),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.white.withAlpha(30),
        highlightColor: Colors.white.withAlpha(80),
        child: Container(
          height: 320,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar la Pokédex',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.white.withAlpha(150)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(pokemonListProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
