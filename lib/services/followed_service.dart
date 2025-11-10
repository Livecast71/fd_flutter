import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FollowedService {
  static const String _followedKey = 'followed_series';

  /// Get all followed series names
  Future<Set<String>> getFollowedSeries() async {
    final prefs = await SharedPreferences.getInstance();
    final followedJson = prefs.getString(_followedKey);
    if (followedJson == null) {
      return <String>{};
    }
    try {
      final List<dynamic> followed = jsonDecode(followedJson);
      return followed.map((e) => e.toString()).toSet();
    } catch (e) {
      return <String>{};
    }
  }

  /// Check if a series is followed
  Future<bool> isFollowed(String seriesName) async {
    final followed = await getFollowedSeries();
    return followed.contains(seriesName);
  }

  /// Follow a series
  Future<bool> followSeries(String seriesName) async {
    final prefs = await SharedPreferences.getInstance();
    final followed = await getFollowedSeries();
    followed.add(seriesName);
    final followedJson = jsonEncode(followed.toList());
    return await prefs.setString(_followedKey, followedJson);
  }

  /// Unfollow a series
  Future<bool> unfollowSeries(String seriesName) async {
    final prefs = await SharedPreferences.getInstance();
    final followed = await getFollowedSeries();
    followed.remove(seriesName);
    final followedJson = jsonEncode(followed.toList());
    return await prefs.setString(_followedKey, followedJson);
  }

  /// Toggle follow status
  Future<bool> toggleFollow(String seriesName) async {
    final currentlyFollowed = await isFollowed(seriesName);
    if (currentlyFollowed) {
      return await unfollowSeries(seriesName);
    } else {
      return await followSeries(seriesName);
    }
  }
}

