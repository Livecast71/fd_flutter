import 'dart:async';
import 'package:flutter/material.dart';
import '../models/program.dart';
import '../widgets/mini_player_widget.dart';
import 'programs_screen.dart';
import 'favorites_screen.dart';
import 'followed_screen.dart';
import 'downloads_screen.dart';
import 'episode_detail_screen.dart';
import 'settings_screen.dart';
import '../services/audio_player_service.dart';

class MainTabScreen extends StatefulWidget {
  final Program program;
  final VoidCallback? onThemeChanged;

  const MainTabScreen({
    super.key,
    required this.program,
    this.onThemeChanged,
  });

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  final AudioPlayerService _audioService = AudioPlayerService();
  StreamSubscription? _playerStateSubscription;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      ProgramsScreen(program: widget.program),
      FavoritesScreen(program: widget.program),
      FollowedScreen(program: widget.program),
      DownloadsScreen(program: widget.program),
    ]);
    
    // Listen to player state changes to rebuild when episode changes
    _playerStateSubscription = _audioService.playerStateStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentEpisode = _audioService.currentEpisode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FD Podcast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
              // Refresh theme if changed
              widget.onThemeChanged?.call();
            },
            tooltip: 'Instellingen',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player (shown when audio is playing)
          MiniPlayerWidget(
            onTap: currentEpisode != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EpisodeDetailScreen(
                          episode: currentEpisode,
                          podcastTitle: currentEpisode.seriesName,
                        ),
                      ),
                    );
                  }
                : null,
          ),
          // Bottom navigation bar
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books),
                label: 'Programma\'s',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favorieten',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: 'Gevolgd',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.download),
                label: 'Downloads',
              ),
            ],
            type: BottomNavigationBarType.fixed,
          ),
        ],
      ),
    );
  }
}

