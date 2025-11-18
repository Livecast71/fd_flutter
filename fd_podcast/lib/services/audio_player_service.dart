import 'package:just_audio/just_audio.dart';
import 'dart:io';
import '../models/episode.dart';
import 'download_service.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final DownloadService _downloadService = DownloadService();
  Episode? _currentEpisode;

  AudioPlayer get player => _audioPlayer;
  Episode? get currentEpisode => _currentEpisode;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  Future<void> playEpisode(Episode episode) async {
    try {
      if (_currentEpisode?.guid != episode.guid) {
        // New episode, load it
        // Check if downloaded first, otherwise use URL
        final localPath = await _downloadService.getLocalFilePath(episode.guid);
        if (localPath != null && await File(localPath).exists()) {
          // Play from local file
          await _audioPlayer.setFilePath(localPath);
        } else {
          // Play from URL
          await _audioPlayer.setUrl(episode.audioUrl);
        }
        _currentEpisode = episode;
      }
      await _audioPlayer.play();
    } catch (e) {
      throw Exception('Failed to play episode: $e');
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentEpisode = null;
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }

  bool get isPlaying => _audioPlayer.playing;
  bool get isPaused => _audioPlayer.playerState.processingState == ProcessingState.ready && !_audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

