import 'package:flutter/material.dart';
import '../models/program.dart';
import '../models/series.dart';
import '../services/followed_service.dart';
import 'series_screen.dart';

class ProgramsScreen extends StatelessWidget {
  final Program program;

  const ProgramsScreen({
    super.key,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomScrollView(
        slivers: [
          // Program header
          if (program.imageUrl != null || program.description != null)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    if (program.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          program.imageUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: theme.colorScheme.secondary,
                              child: const Icon(
                                Icons.podcasts,
                                size: 60,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      program.name,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (program.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        program.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      '${program.series.length} series • ${program.totalEpisodes} afleveringen',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Series list
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final series = program.series[index];
                  return _SeriesCardWithFollow(
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
                childCount: program.series.length,
              ),
            ),
          ),
        ],
      );
  }
}

class _SeriesCardWithFollow extends StatefulWidget {
  final Series series;
  final VoidCallback onTap;

  const _SeriesCardWithFollow({
    required this.series,
    required this.onTap,
  });

  @override
  State<_SeriesCardWithFollow> createState() => _SeriesCardWithFollowState();
}

class _SeriesCardWithFollowState extends State<_SeriesCardWithFollow> {
  final FollowedService _followedService = FollowedService();
  bool _isFollowed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final isFollowed = await _followedService.isFollowed(widget.series.name);
    setState(() {
      _isFollowed = isFollowed;
      _isLoading = false;
    });
  }

  Future<void> _toggleFollow() async {
    await _followedService.toggleFollow(widget.series.name);
    await _checkFollowStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Series image
              if (widget.series.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.series.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.secondary,
                        child: const Icon(Icons.podcasts, size: 40),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.podcasts, size: 40),
                ),
              const SizedBox(width: 12),
              // Series info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.series.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.series.episodeCount} afleveringen',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (widget.series.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.series.description!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isFollowed ? Icons.bookmark : Icons.bookmark_border,
                        color: _isFollowed
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                onPressed: _toggleFollow,
                tooltip: _isFollowed ? 'Ontvolgen' : 'Volgen',
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

