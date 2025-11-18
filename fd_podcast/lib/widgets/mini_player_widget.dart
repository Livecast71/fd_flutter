import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';

class MiniPlayerWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const MiniPlayerWidget({
    super.key,
    this.onTap,
  });

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  final AudioPlayerService _audioService = AudioPlayerService();
  bool _isPlaying = false;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _playerStateSubscription = _audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.resume();
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final episode = _audioService.currentEpisode;
    
    // Don't show if no episode is playing
    if (episode == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // Episode image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    episode.imageUrl.isNotEmpty
                        ? episode.imageUrl
                        : 'https://via.placeholder.com/50',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: theme.colorScheme.secondary,
                        child: const Icon(Icons.podcasts, size: 24),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Episode info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        episode.seriesName,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Play/Pause button
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _playPause,
                  tooltip: _isPlaying ? 'Pause' : 'Play',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

