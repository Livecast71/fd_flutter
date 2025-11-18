import 'episode.dart';

class Series {
  final String name;
  final String? description;
  final String? imageUrl;
  final List<Episode> episodes;

  Series({
    required this.name,
    this.description,
    this.imageUrl,
    required this.episodes,
  });

  int get episodeCount => episodes.length;
  
  Episode? get latestEpisode {
    if (episodes.isEmpty) return null;
    episodes.sort((a, b) => b.pubDate.compareTo(a.pubDate));
    return episodes.first;
  }
}

