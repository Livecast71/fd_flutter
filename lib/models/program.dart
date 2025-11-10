import 'series.dart';

class Program {
  final String name;
  final String? description;
  final String? imageUrl;
  final List<Series> series;

  Program({
    required this.name,
    this.description,
    this.imageUrl,
    required this.series,
  });

  int get totalEpisodes {
    return series.fold(0, (sum, s) => sum + s.episodes.length);
  }
}

