import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/episode.dart';

class DownloadService {
  static const String _downloadsKey = 'downloaded_episodes';
  static const String _downloadsDirName = 'fd_podcast_downloads';

  /// Get the downloads directory
  Future<Directory> _getDownloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${appDir.path}/$_downloadsDirName');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir;
  }

  /// Get the file path for an episode
  Future<String> _getEpisodeFilePath(String guid) async {
    final downloadsDir = await _getDownloadsDirectory();
    return '${downloadsDir.path}/$guid.mp3';
  }

  /// Get all downloaded episode GUIDs
  Future<Set<String>> getDownloadedGuids() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadsJson = prefs.getString(_downloadsKey);
    if (downloadsJson == null) {
      return <String>{};
    }
    try {
      final List<dynamic> downloads = jsonDecode(downloadsJson);
      return downloads.map((e) => e.toString()).toSet();
    } catch (e) {
      return <String>{};
    }
  }

  /// Check if an episode is downloaded
  Future<bool> isDownloaded(String guid) async {
    final downloadedGuids = await getDownloadedGuids();
    if (!downloadedGuids.contains(guid)) {
      return false;
    }
    // Also check if file actually exists
    final filePath = await _getEpisodeFilePath(guid);
    final file = File(filePath);
    return await file.exists();
  }

  /// Get local file path for episode (returns null if not downloaded)
  Future<String?> getLocalFilePath(String guid) async {
    if (await isDownloaded(guid)) {
      return await _getEpisodeFilePath(guid);
    }
    return null;
  }

  /// Download an episode
  Future<bool> downloadEpisode(Episode episode, {
    Function(int received, int total)? onProgress,
  }) async {
    try {
      final filePath = await _getEpisodeFilePath(episode.guid);
      final file = File(filePath);

      // Check if already downloaded
      if (await file.exists()) {
        await _addToDownloadedList(episode.guid);
        return true;
      }

      // Download the file
      final response = await http.get(
        Uri.parse(episode.audioUrl),
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        await _addToDownloadedList(episode.guid);
        return true;
      } else {
        throw Exception('Failed to download: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading episode: $e');
    }
  }

  /// Add episode to downloaded list
  Future<void> _addToDownloadedList(String guid) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedGuids = await getDownloadedGuids();
    downloadedGuids.add(guid);
    final downloadsJson = jsonEncode(downloadedGuids.toList());
    await prefs.setString(_downloadsKey, downloadsJson);
  }

  /// Delete downloaded episode
  Future<bool> deleteDownload(String guid) async {
    try {
      final filePath = await _getEpisodeFilePath(guid);
      final file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from downloaded list
      final prefs = await SharedPreferences.getInstance();
      final downloadedGuids = await getDownloadedGuids();
      downloadedGuids.remove(guid);
      final downloadsJson = jsonEncode(downloadedGuids.toList());
      await prefs.setString(_downloadsKey, downloadsJson);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get download size for an episode
  Future<int?> getDownloadSize(String guid) async {
    try {
      final filePath = await _getEpisodeFilePath(guid);
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  /// Get total size of all downloads
  Future<int> getTotalDownloadsSize() async {
    try {
      final downloadsDir = await _getDownloadsDirectory();
      int totalSize = 0;
      
      if (await downloadsDir.exists()) {
        await for (var entity in downloadsDir.list(recursive: false)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Format bytes to human readable string
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

