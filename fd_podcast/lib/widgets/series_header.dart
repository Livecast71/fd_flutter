import 'package:flutter/material.dart';
import '../models/series.dart';

class SeriesHeader extends StatelessWidget {
  final Series series;

  const SeriesHeader({
    super.key,
    required this.series,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
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
          if (series.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                series.imageUrl!,
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
            series.name,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${series.episodeCount} afleveringen',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          if (series.description != null) ...[
            const SizedBox(height: 16),
            Text(
              series.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

