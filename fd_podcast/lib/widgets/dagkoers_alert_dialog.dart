import 'package:flutter/material.dart';
import '../models/episode.dart';

class DagkoersAlertDialog extends StatelessWidget {
  final Episode episode;
  final VoidCallback onViewEpisode;
  final VoidCallback onDismiss;

  const DagkoersAlertDialog({
    super.key,
    required this.episode,
    required this.onViewEpisode,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'FD Dagkoers beschikbaar!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Er is een nieuwe aflevering van FD Dagkoers beschikbaar.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (episode.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    episode.description.length > 100
                        ? '${episode.description.substring(0, 100)}...'
                        : episode.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: onViewEpisode,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Bekijk aflevering'),
        ),
      ],
    );
  }
}

