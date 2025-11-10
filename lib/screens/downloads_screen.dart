import 'package:flutter/material.dart';
import '../models/program.dart';
import '../models/episode.dart';
import '../services/download_service.dart';
import '../widgets/episode_card.dart';
import '../widgets/episode_search_bar.dart';
import 'episode_detail_screen.dart';

class DownloadsScreen extends StatefulWidget {
  final Program program;

  const DownloadsScreen({
    super.key,
    required this.program,
  });

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final DownloadService _downloadService = DownloadService();
  List<Episode> _downloadedEpisodes = [];
  List<Episode> _filteredEpisodes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    setState(() {
      _isLoading = true;
    });

    // Get all episodes from all series
    final allEpisodes = <Episode>[];
    for (var series in widget.program.series) {
      allEpisodes.addAll(series.episodes);
    }

    // Filter to only downloaded episodes
    final downloadedGuids = await _downloadService.getDownloadedGuids();
    final downloaded = allEpisodes
        .where((episode) => downloadedGuids.contains(episode.guid))
        .toList();
    
    // Sort by date (newest first)
    downloaded.sort((a, b) => b.pubDate.compareTo(a.pubDate));

    setState(() {
      _downloadedEpisodes = downloaded;
      _filteredEpisodes = downloaded;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredEpisodes = _downloadedEpisodes;
      } else {
        _filteredEpisodes = _downloadedEpisodes.where((episode) {
          return episode.title.toLowerCase().contains(_searchQuery) ||
              episode.description.toLowerCase().contains(_searchQuery) ||
              episode.seriesName.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _getTotalSize() async {
    final totalSize = await _downloadService.getTotalDownloadsSize();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Opslaggebruik'),
          content: Text(
            'Totaal gebruikt: ${_downloadService.formatBytes(totalSize)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_downloadedEpisodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Geen downloads',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Download afleveringen om ze offline te beluisteren',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDownloads,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: EpisodeSearchBar(
              onSearchChanged: _onSearchChanged,
              hintText: 'Zoek in downloads...',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredEpisodes.length} van ${_downloadedEpisodes.length} gedownloade afleveringen',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: _getTotalSize,
                    tooltip: 'Opslaggebruik bekijken',
                  ),
                ],
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
                        // Reload downloads when returning from detail screen
                        _loadDownloads();
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

