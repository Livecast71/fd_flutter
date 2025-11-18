import 'package:flutter/material.dart';
import '../models/program.dart';
import '../models/episode.dart';
import '../services/rss_service.dart';
import '../services/dagkoers_alert_service.dart';
import '../widgets/dagkoers_alert_dialog.dart';
import 'main_tab_screen.dart';
import 'episode_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RssService _rssService = RssService();
  final DagkoersAlertService _alertService = DagkoersAlertService();
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
      
      // Check for new FD Dagkoers episode after loading
      _checkForDagkoersAlert(program);
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
                'Error loading podcast',
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
                child: const Text('Retry'),
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
          child: Text('No podcast data available'),
        ),
      );
    }

    return MainTabScreen(program: _program!);
  }

  Future<void> _checkForDagkoersAlert(Program program) async {
    // Wait for the widget tree to be built before showing the dialog
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final episode = await _alertService.checkForNewDagkoersEpisode(program);
    
    if (episode != null && mounted) {
      // Mark as alerted before showing dialog
      await _alertService.markEpisodeAsAlerted(episode);
      
      // Show alert dialog
      _showDagkoersAlert(episode);
    }
  }

  void _showDagkoersAlert(Episode episode) {
    showDialog(
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
}

