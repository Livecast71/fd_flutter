import 'package:flutter/material.dart';
import '../models/podcast.dart';

class PodcastHeader extends StatelessWidget {
  final Podcast podcast;

  const PodcastHeader({
    super.key,
    required this.podcast,
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
          if (podcast.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                podcast.imageUrl,
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
            podcast.title,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            podcast.author,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          if (podcast.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              podcast.description,
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

