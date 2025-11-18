import 'dart:convert';
import '../models/episode.dart';
import '../models/program.dart';
import '../models/series.dart';
import 'followed_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowedAlertService {
  static const String _lastSeenEpisodesKey = 'last_seen_episodes';
  final FollowedService _followedService = FollowedService();

  /// Get the last seen episode GUID for each series
  Future<Map<String, String>> getLastSeenEpisodes() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeenJson = prefs.getString(_lastSeenEpisodesKey);
    if (lastSeenJson == null) {
      return <String, String>{};
    }
    try {
      final Map<String, dynamic> lastSeen = jsonDecode(lastSeenJson);
      return lastSeen.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return <String, String>{};
    }
  }

  /// Mark an episode as seen for a series
  Future<void> markEpisodeAsSeen(String seriesName, Episode episode) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeen = await getLastSeenEpisodes();
    lastSeen[seriesName] = episode.guid;
    final lastSeenJson = jsonEncode(lastSeen);
    await prefs.setString(_lastSeenEpisodesKey, lastSeenJson);
  }

  /// Check if there are new episodes in followed series
  /// Returns a list of episodes that are new (user hasn't seen them yet)
  Future<List<Episode>> checkForNewFollowedEpisodes(Program program) async {
    try {
      final followedSeriesNames = await _followedService.getFollowedSeries();
      
      if (followedSeriesNames.isEmpty) {
        return [];
      }

      final lastSeenEpisodes = await getLastSeenEpisodes();
      final List<Episode> newEpisodes = [];

      // Check each followed series
      for (final seriesName in followedSeriesNames) {
        // Find the series in the program
        final series = program.series.firstWhere(
          (s) => s.name == seriesName,
          orElse: () => throw Exception('Series not found: $seriesName'),
        );

        if (series.episodes.isEmpty) {
          continue;
        }

        // Get the latest episode (episodes are already sorted by date, newest first)
        final latestEpisode = series.episodes.first;
        
        // Check if user has seen this episode
        final lastSeenGuid = lastSeenEpisodes[seriesName];
        
        // If no last seen episode, mark the current latest as seen (don't alert on first check)
        if (lastSeenGuid == null) {
          // Mark the latest episode as seen so we don't alert on first check
          await markEpisodeAsSeen(seriesName, latestEpisode);
          continue;
        }

        // If the latest episode GUID is different from what we've seen, it's new
        if (latestEpisode.guid != lastSeenGuid) {
          newEpisodes.add(latestEpisode);
        }
      }

      return newEpisodes;
    } catch (e) {
      // If any error occurs, return empty list
      return [];
    }
  }

  /// Clear last seen episodes for a specific series (useful for testing)
  Future<void> clearLastSeenForSeries(String seriesName) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeen = await getLastSeenEpisodes();
    lastSeen.remove(seriesName);
    final lastSeenJson = jsonEncode(lastSeen);
    await prefs.setString(_lastSeenEpisodesKey, lastSeenJson);
  }

  /// Clear all last seen episodes (useful for testing)
  Future<void> clearAllLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSeenEpisodesKey);
  }
}

