import 'package:flutter/material.dart';
import '../models/series.dart';
import '../models/episode.dart';
import '../widgets/episode_card.dart';
import '../widgets/series_header.dart';
import '../widgets/episode_search_bar.dart';
import 'episode_detail_screen.dart';

class SeriesScreen extends StatefulWidget {
  final Series series;

  const SeriesScreen({
    super.key,
    required this.series,
  });

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  String _searchQuery = '';
  List<Episode> _filteredEpisodes = [];

  @override
  void initState() {
    super.initState();
    _filteredEpisodes = widget.series.episodes;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredEpisodes = widget.series.episodes;
      } else {
        _filteredEpisodes = widget.series.episodes.where((episode) {
          return episode.title.toLowerCase().contains(_searchQuery) ||
              episode.description.toLowerCase().contains(_searchQuery) ||
              episode.seriesName.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.series.name),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SeriesHeader(series: widget.series),
          ),
          SliverToBoxAdapter(
            child: EpisodeSearchBar(
              onSearchChanged: _onSearchChanged,
              hintText: 'Zoek in ${widget.series.name}...',
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EpisodeDetailScreen(
                              episode: episode,
                              podcastTitle: widget.series.name,
                            ),
                          ),
                        );
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

