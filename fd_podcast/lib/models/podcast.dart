import 'episode.dart';

class Podcast {
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final String author;
  final List<Episode> episodes;

  Podcast({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.author,
    required this.episodes,
  });
}

