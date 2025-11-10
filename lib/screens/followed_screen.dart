import 'package:flutter/material.dart';
import '../models/program.dart';
import '../models/series.dart';
import '../services/followed_service.dart';
import 'series_screen.dart';
import '../widgets/series_card.dart';

class FollowedScreen extends StatefulWidget {
  final Program program;

  const FollowedScreen({
    super.key,
    required this.program,
  });

  @override
  State<FollowedScreen> createState() => _FollowedScreenState();
}

class _FollowedScreenState extends State<FollowedScreen> {
  final FollowedService _followedService = FollowedService();
  List<Series> _followedSeries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowed();
  }

  Future<void> _loadFollowed() async {
    setState(() {
      _isLoading = true;
    });

    final followedNames = await _followedService.getFollowedSeries();
    final followed = widget.program.series
        .where((series) => followedNames.contains(series.name))
        .toList();

    setState(() {
      _followedSeries = followed;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_followedSeries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Geen gevolgde series',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Volg series om ze hier te zien',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowed,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${_followedSeries.length} gevolgde series',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final series = _followedSeries[index];
                  return SeriesCard(
                    series: series,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeriesScreen(series: series),
                        ),
                      );
                    },
                  );
                },
                childCount: _followedSeries.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

