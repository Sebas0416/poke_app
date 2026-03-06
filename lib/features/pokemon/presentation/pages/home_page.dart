import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_app/core/network/connectivity_service.dart';
import 'package:poke_app/core/router/app_router.dart';
import 'package:poke_app/core/widgets/gradient_background.dart';
import 'package:poke_app/features/pokemon/presentation/providers/pokemon_provider.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/offline_banner.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_carousel.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_counter.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/pokemon_error_state.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/refresh_button.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/search_bar_widget.dart';
import 'package:poke_app/features/pokemon/presentation/widgets/type_filter_row.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _showRefreshButton = false;
  bool _wasOffline = false;

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
      resizeToAvoidBottomInset: false,
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
                  const SearchBarWidget(),
                  const SizedBox(height: 12),
                  const TypeFilterRow(),
                  const SizedBox(height: 8),
                  const PokemonCounter(),
                  const SizedBox(height: 4),
                  Expanded(
                    child: switch (pokemonState) {
                      PokemonListInitial() ||
                      PokemonListLoading() =>
                        _buildLoading(),
                      PokemonListError(:final message) =>
                        PokemonErrorState(message: message),
                      PokemonListLoaded(:final isLoadingMore) =>
                        PokemonCarousel(isLoadingMore: isLoadingMore),
                      PokemonListState() => throw UnimplementedError(),
                    },
                  ),
                ],
              ),
              if (_showRefreshButton)
                Positioned(
                  bottom: 80,
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
}
