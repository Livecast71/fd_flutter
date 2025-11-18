class Episode {
  final String title;
  final String description;
  final String audioUrl;
  final String imageUrl;
  final DateTime pubDate;
  final int duration; // in seconds
  final String guid;
  final String link;
  final String seriesName; // Series this episode belongs to

  Episode({
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.imageUrl,
    required this.pubDate,
    required this.duration,
    required this.guid,
    required this.link,
    required this.seriesName,
  });

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return '${pubDate.day}/${pubDate.month}/${pubDate.year}';
  }
}

