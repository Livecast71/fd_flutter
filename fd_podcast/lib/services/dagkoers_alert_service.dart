import '../models/episode.dart';
import '../models/program.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DagkoersAlertService {
  static const String _lastAlertedEpisodeKey = 'last_alerted_dagkoers_episode';
  static const String dagkoersSeriesName = 'FD Dagkoers';
  static const int alertTimeHour = 16; // 4:00 PM

  /// Check if there's a new FD Dagkoers episode published before 16:00 today
  /// Returns the episode if found, null otherwise
  Future<Episode?> checkForNewDagkoersEpisode(Program program) async {
    try {
      // Find FD Dagkoers series
      final dagkoersSeries = program.series.firstWhere(
        (series) => series.name == dagkoersSeriesName,
        orElse: () => throw Exception('FD Dagkoers series not found'),
      );

      if (dagkoersSeries.episodes.isEmpty) {
        return null;
      }

      // Get the most recent episode
      final latestEpisode = dagkoersSeries.episodes.first;

      // Check if episode was published today
      final now = DateTime.now();
      final episodeDate = latestEpisode.pubDate;
      
      // Check if episode is from today
      final isToday = episodeDate.year == now.year &&
          episodeDate.month == now.month &&
          episodeDate.day == now.day;

      if (!isToday) {
        return null;
      }

      // Check if episode was published before 16:00 (4:00 PM) in local time
      final episodeHour = episodeDate.hour;
      if (episodeHour >= alertTimeHour) {
        return null;
      }

      // Check if we've already alerted about this episode
      final prefs = await SharedPreferences.getInstance();
      final lastAlertedGuid = prefs.getString(_lastAlertedEpisodeKey);
      
      if (lastAlertedGuid == latestEpisode.guid) {
        return null; // Already alerted about this episode
      }

      // Episode is from today, published before 16:00, and we haven't alerted yet
      return latestEpisode;
    } catch (e) {
      // If FD Dagkoers series not found or any error, return null
      return null;
    }
  }

  /// Mark an episode as alerted
  Future<void> markEpisodeAsAlerted(Episode episode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAlertedEpisodeKey, episode.guid);
  }

  /// Clear the last alerted episode (useful for testing)
  Future<void> clearLastAlertedEpisode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastAlertedEpisodeKey);
  }
}

