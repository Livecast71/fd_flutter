import 'package:flutter/material.dart';
import '../models/program.dart';
import '../services/rss_service.dart';
import 'main_tab_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RssService _rssService = RssService();
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
}

