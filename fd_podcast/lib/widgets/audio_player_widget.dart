import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/episode.dart';
import '../services/audio_player_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Episode episode;

  const AudioPlayerWidget({
    super.key,
    required this.episode,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayerService _audioService = AudioPlayerService();
  Duration _position = Duration.zero;
  Duration? _duration;
  bool _isPlaying = false;
  bool _isLoading = false;
  double _playbackSpeed = 1.0;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _setupListeners();
  }

  void _initializePlayer() {
    final currentEpisode = _audioService.currentEpisode;
    if (currentEpisode?.guid == widget.episode.guid) {
      // Same episode, just update UI
      _updateUI();
    }
  }

  void _setupListeners() {
    _positionSubscription = _audioService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _durationSubscription = _audioService.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _playerStateSubscription = _audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  void _updateUI() {
    setState(() {
      _position = _audioService.position;
      _duration = _audioService.duration;
      _isPlaying = _audioService.isPlaying;
    });
  }

  Future<void> _playPause() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_audioService.currentEpisode?.guid != widget.episode.guid) {
        await _audioService.playEpisode(widget.episode);
      } else {
        if (_isPlaying) {
          await _audioService.pause();
        } else {
          await _audioService.resume();
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> _changeSpeed() async {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    final currentIndex = speeds.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % speeds.length;
    _playbackSpeed = speeds[nextIndex];
    await _audioService.setSpeed(_playbackSpeed);
    setState(() {});
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          if (_duration != null)
            Column(
              children: [
                Slider(
                  value: _position.inMilliseconds.toDouble().clamp(
                    0.0,
                    _duration!.inMilliseconds.toDouble(),
                  ),
                  min: 0.0,
                  max: _duration!.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    _seek(Duration(milliseconds: value.toInt()));
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      _formatDuration(_duration!),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 16),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Speed button
              IconButton(
                icon: Text(
                  '${_playbackSpeed}x',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _changeSpeed,
                tooltip: 'Playback speed',
              ),
              const SizedBox(width: 8),
              // Rewind 10 seconds
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () async {
                  final newPosition = _position - const Duration(seconds: 10);
                  await _seek(newPosition < Duration.zero ? Duration.zero : newPosition);
                },
                tooltip: 'Rewind 10 seconds',
              ),
              const SizedBox(width: 8),
              // Play/Pause button
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                  iconSize: 32,
                  onPressed: _playPause,
                  tooltip: _isPlaying ? 'Pause' : 'Play',
                ),
              ),
              const SizedBox(width: 8),
              // Forward 10 seconds
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () async {
                  if (_duration != null) {
                    final newPosition = _position + const Duration(seconds: 10);
                    await _seek(newPosition > _duration! ? _duration! : newPosition);
                  }
                },
                tooltip: 'Forward 10 seconds',
              ),
              const SizedBox(width: 8),
              // Stop button
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () async {
                  await _audioService.stop();
                },
                tooltip: 'Stop',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

