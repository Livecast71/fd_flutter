import 'package:flutter/material.dart';
import '../models/program.dart';
import '../models/episode.dart';
import '../services/favorites_service.dart';
import '../widgets/episode_card.dart';
import '../widgets/episode_search_bar.dart';
import 'episode_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final Program program;

  const FavoritesScreen({
    super.key,
    required this.program,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Episode> _favoriteEpisodes = [];
  List<Episode> _filteredEpisodes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    // Get all episodes from all series
    final allEpisodes = <Episode>[];
    for (var series in widget.program.series) {
      allEpisodes.addAll(series.episodes);
    }

    final favorites = await _favoritesService.getFavoriteEpisodes(allEpisodes);
    
    setState(() {
      _favoriteEpisodes = favorites;
      _filteredEpisodes = favorites;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredEpisodes = _favoriteEpisodes;
      } else {
        _filteredEpisodes = _favoriteEpisodes.where((episode) {
          return episode.title.toLowerCase().contains(_searchQuery) ||
              episode.description.toLowerCase().contains(_searchQuery) ||
              episode.seriesName.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_favoriteEpisodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Geen favorieten',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Voeg afleveringen toe aan je favorieten',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: EpisodeSearchBar(
              onSearchChanged: _onSearchChanged,
              hintText: 'Zoek in favorieten...',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${_filteredEpisodes.length} van ${_favoriteEpisodes.length} favoriete afleveringen',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          if (_filteredEpisodes.isEmpty && _searchQuery.isNotEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Geen resultaten gevonden',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Probeer andere zoektermen',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final episode = _filteredEpisodes[index];
                    return EpisodeCard(
                      episode: episode,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EpisodeDetailScreen(
                              episode: episode,
                              podcastTitle: episode.seriesName,
                            ),
                          ),
                        );
                        // Reload favorites when returning from detail screen
                        _loadFavorites();
                      },
                    );
                  },
                  childCount: _filteredEpisodes.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

