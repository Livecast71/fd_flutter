import 'package:flutter/material.dart';
import '../models/program.dart';
import '../models/episode.dart';
import '../services/rss_service.dart';
import '../services/dagkoers_alert_service.dart';
import '../services/followed_alert_service.dart';
import '../widgets/dagkoers_alert_dialog.dart';
import '../widgets/new_episode_alert_dialog.dart';
import 'main_tab_screen.dart';
import 'episode_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  
  const HomeScreen({super.key, this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RssService _rssService = RssService();
  final DagkoersAlertService _dagkoersAlertService = DagkoersAlertService();
  final FollowedAlertService _followedAlertService = FollowedAlertService();
  Program? _program;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPodcast();
  }

  Future<void> _loadPodcast() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final podcast = await _rssService.fetchPodcast();
      final program = _rssService.organizeIntoPrograms(podcast);
      setState(() {
        _program = program;
        _isLoading = false;
      });
      
      // Check for alerts after loading (Dagkoers first, then followed podcasts)
      _checkForAlerts(program);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('FD Podcast'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('FD Podcast'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Fout bij laden podcast',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadPodcast,
                child: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_program == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('FD Podcast'),
        ),
        body: const Center(
          child: Text('Geen podcast gegevens beschikbaar'),
        ),
      );
    }

    return MainTabScreen(
      program: _program!,
      onThemeChanged: widget.onThemeChanged,
    );
  }

  Future<void> _checkForAlerts(Program program) async {
    // Wait for the widget tree to be built before showing the dialog
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    // Check for FD Dagkoers alert first (priority)
    final dagkoersEpisode = await _dagkoersAlertService.checkForNewDagkoersEpisode(program);
    
    if (dagkoersEpisode != null && mounted) {
      // Mark as alerted before showing dialog
      await _dagkoersAlertService.markEpisodeAsAlerted(dagkoersEpisode);
      
      // Show alert dialog and wait for it to be dismissed
      await _showDagkoersAlert(dagkoersEpisode);
    }
    
    // After Dagkoers alert (or if none), check for followed podcast alerts
    if (!mounted) return;
    
    final newFollowedEpisodes = await _followedAlertService.checkForNewFollowedEpisodes(program);
    
    if (newFollowedEpisodes.isNotEmpty && mounted) {
      // Show alerts for each new followed episode sequentially
      for (final episode in newFollowedEpisodes) {
        if (!mounted) break;
        
        // Show alert and wait for user action
        await _showFollowedAlert(episode);
      }
    }
  }

  Future<void> _showDagkoersAlert(Episode episode) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return DagkoersAlertDialog(
          episode: episode,
          onViewEpisode: () {
            Navigator.of(context).pop(); // Close dialog
            // Navigate to episode detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EpisodeDetailScreen(
                  episode: episode,
                  podcastTitle: episode.seriesName,
                ),
              ),
            );
          },
          onDismiss: () {
            Navigator.of(context).pop(); // Close dialog
          },
        );
      },
    );
  }

  Future<void> _showFollowedAlert(Episode episode) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return NewEpisodeAlertDialog(
          episode: episode,
          seriesName: episode.seriesName,
          onViewEpisode: () async {
            Navigator.of(context).pop(); // Close dialog
            // Mark episode as seen when user views it
            await _followedAlertService.markEpisodeAsSeen(episode.seriesName, episode);
            // Navigate to episode detail screen
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EpisodeDetailScreen(
                    episode: episode,
                    podcastTitle: episode.seriesName,
                  ),
                ),
              );
            }
          },
          onDismiss: () async {
            Navigator.of(context).pop(); // Close dialog
            // Mark episode as seen even if dismissed (so we don't alert again)
            await _followedAlertService.markEpisodeAsSeen(episode.seriesName, episode);
          },
        );
      },
    );
  }
}

