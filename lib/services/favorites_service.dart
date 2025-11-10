import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/episode.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_episodes';

  /// Get all favorite episode GUIDs
  Future<Set<String>> getFavoriteGuids() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson == null) {
      return <String>{};
    }
    try {
      final List<dynamic> favorites = jsonDecode(favoritesJson);
      return favorites.map((e) => e.toString()).toSet();
    } catch (e) {
      return <String>{};
    }
  }

  /// Check if an episode is favorited
  Future<bool> isFavorite(String guid) async {
    final favorites = await getFavoriteGuids();
    return favorites.contains(guid);
  }

  /// Add an episode to favorites
  Future<bool> addFavorite(String guid) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteGuids();
    favorites.add(guid);
    final favoritesJson = jsonEncode(favorites.toList());
    return await prefs.setString(_favoritesKey, favoritesJson);
  }

  /// Remove an episode from favorites
  Future<bool> removeFavorite(String guid) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteGuids();
    favorites.remove(guid);
    final favoritesJson = jsonEncode(favorites.toList());
    return await prefs.setString(_favoritesKey, favoritesJson);
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String guid) async {
    final isFav = await isFavorite(guid);
    if (isFav) {
      return await removeFavorite(guid);
    } else {
      return await addFavorite(guid);
    }
  }

  /// Get favorite episodes from a list of episodes
  Future<List<Episode>> getFavoriteEpisodes(List<Episode> allEpisodes) async {
    final favoriteGuids = await getFavoriteGuids();
    return allEpisodes.where((episode) => favoriteGuids.contains(episode.guid)).toList()
      ..sort((a, b) => b.pubDate.compareTo(a.pubDate));
  }
}

