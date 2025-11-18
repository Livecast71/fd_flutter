import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import '../models/podcast.dart';
import '../models/episode.dart';
import '../models/series.dart';
import '../models/program.dart';

class RssService {
  static const String rssUrl =
      'https://www.omnycontent.com/d/playlist/8257a063-6be9-42fa-b892-acd4013b1255/7c7183f7-003f-4fcf-a5e3-addc00ff4d48/610741e8-1c7a-4f89-ae3e-addc00ffe9ca/podcast.rss';

  Future<Podcast> fetchPodcast() async {
    try {
      final response = await http.get(Uri.parse(rssUrl));
      if (response.statusCode == 200) {
        return _parseRssFeed(response.body);
      } else {
        throw Exception('Failed to load podcast: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching podcast: $e');
    }
  }

  Podcast _parseRssFeed(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final channel = document.findAllElements('channel').first;

    // Parse channel info
    final title = channel.findElements('title').first.innerText;
    final description = _parseDescription(channel.findElements('description').first.innerText);
    final link = channel.findElements('link').first.innerText;
    final author = channel.findElements('itunes:author').first.innerText;
    
    // Parse image
    String imageUrl = '';
    final imageElement = channel.findElements('image').firstOrNull;
    if (imageElement != null) {
      final urlElement = imageElement.findElements('url').firstOrNull;
      if (urlElement != null) {
        imageUrl = urlElement.innerText;
      }
    }
    
    // Fallback to itunes:image if image not found
    if (imageUrl.isEmpty) {
      final itunesImage = channel.findElements('itunes:image').firstOrNull;
      if (itunesImage != null) {
        imageUrl = itunesImage.getAttribute('href') ?? '';
      }
    }

    // Parse episodes
    final items = channel.findElements('item');
    final episodes = items.map((item) => _parseEpisode(item)).toList();

    return Podcast(
      title: title,
      description: description,
      imageUrl: imageUrl,
      link: link,
      author: author,
      episodes: episodes,
    );
  }

  Episode _parseEpisode(XmlElement item) {
    final title = item.findElements('title').first.innerText;
    final description = _parseDescription(item.findElements('description').first.innerText);
    
    // Parse audio URL from enclosure
    String audioUrl = '';
    final enclosure = item.findElements('enclosure').firstOrNull;
    if (enclosure != null) {
      audioUrl = enclosure.getAttribute('url') ?? '';
    }
    
    // Fallback to media:content if enclosure not found
    if (audioUrl.isEmpty) {
      final mediaContent = item.findElements('media:content').firstOrNull;
      if (mediaContent != null) {
        audioUrl = mediaContent.getAttribute('url') ?? '';
      }
    }

    // Parse image
    String imageUrl = '';
    final itunesImage = item.findElements('itunes:image').firstOrNull;
    if (itunesImage != null) {
      imageUrl = itunesImage.getAttribute('href') ?? '';
    }
    
    // Fallback to media:content image
    if (imageUrl.isEmpty) {
      final mediaContents = item.findElements('media:content');
      for (var content in mediaContents) {
        if (content.getAttribute('type') == 'image/jpeg') {
          imageUrl = content.getAttribute('url') ?? '';
          break;
        }
      }
    }

    // Parse date (RSS date format: "Mon, 17 Nov 2025 04:00:00 +0000")
    final pubDateStr = item.findElements('pubDate').first.innerText;
    DateTime pubDate;
    try {
      // Try parsing RFC 822 format
      final dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US');
      pubDate = dateFormat.parse(pubDateStr);
    } catch (e) {
      try {
        // Fallback to ISO format
        pubDate = DateTime.parse(pubDateStr);
      } catch (e2) {
        pubDate = DateTime.now();
      }
    }

    // Parse duration
    int duration = 0;
    final durationStr = item.findElements('itunes:duration').firstOrNull?.innerText ?? '';
    if (durationStr.isNotEmpty) {
      try {
        // Duration can be in format "MM:SS" or just seconds
        if (durationStr.contains(':')) {
          final parts = durationStr.split(':');
          if (parts.length == 2) {
            duration = int.parse(parts[0]) * 60 + int.parse(parts[1]);
          } else if (parts.length == 3) {
            duration = int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2]);
          }
        } else {
          duration = int.parse(durationStr);
        }
      } catch (e) {
        duration = 0;
      }
    }

    final guid = item.findElements('guid').first.innerText;
    final link = item.findElements('link').first.innerText;

    // Extract series name from link URL
    // Example: https://omny.fm/shows/fd-dagkoers/episode-title
    String seriesName = 'Unknown';
    try {
      final uri = Uri.parse(link);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2 && pathSegments[0] == 'shows') {
        // Extract series name from URL path
        String seriesSlug = pathSegments[1];
        // Convert slug to readable name
        seriesName = _slugToSeriesName(seriesSlug);
      } else {
        // Fallback: try to extract from title prefix
        seriesName = _extractSeriesFromTitle(title);
      }
    } catch (e) {
      // Fallback: try to extract from title prefix
      seriesName = _extractSeriesFromTitle(title);
    }

    return Episode(
      title: title,
      description: description,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
      pubDate: pubDate,
      duration: duration,
      guid: guid,
      link: link,
      seriesName: seriesName,
    );
  }

  String _slugToSeriesName(String slug) {
    // Convert URL slug to readable series name
    final seriesMap = {
      'fd-dagkoers': 'FD Dagkoers',
      'de-fd-gazellen-podcast': 'FD-Gazellen',
      'fd-gazellen-podcast': 'FD-Gazellen',
      'fd-toegevoegde-waarde': 'FD Toegevoegde Waarde',
      'fd-dagkoers-podcast': 'FD Dagkoers',
    };
    
    return seriesMap[slug.toLowerCase()] ?? 
           slug.split('-').map((word) => 
             word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
           ).join(' ');
  }

  String _extractSeriesFromTitle(String title) {
    // Try to extract series name from title prefixes
    if (title.startsWith('FD-Gazellen:')) {
      return 'FD-Gazellen';
    } else if (title.toLowerCase().contains('toegevoegde waarde')) {
      return 'FD Toegevoegde Waarde';
    } else if (title.toLowerCase().contains('dagkoers')) {
      return 'FD Dagkoers';
    }
    return 'FD Dagkoers'; // Default fallback
  }

  /// Organize episodes into Programs and Series structure
  Program organizeIntoPrograms(Podcast podcast) {
    // Group episodes by series
    final Map<String, List<Episode>> seriesMap = {};
    
    for (var episode in podcast.episodes) {
      if (!seriesMap.containsKey(episode.seriesName)) {
        seriesMap[episode.seriesName] = [];
      }
      seriesMap[episode.seriesName]!.add(episode);
    }

    // Create Series objects
    final List<Series> series = seriesMap.entries.map((entry) {
      final episodes = entry.value;
      // Sort episodes by date (newest first)
      episodes.sort((a, b) => b.pubDate.compareTo(a.pubDate));
      
      // Get series image from first episode or use podcast default
      String? seriesImage;
      if (episodes.isNotEmpty && episodes.first.imageUrl.isNotEmpty) {
        seriesImage = episodes.first.imageUrl;
      } else if (podcast.imageUrl.isNotEmpty) {
        seriesImage = podcast.imageUrl;
      }

      return Series(
        name: entry.key,
        description: _getSeriesDescription(entry.key),
        imageUrl: seriesImage,
        episodes: episodes,
      );
    }).toList();

    // Sort series by name
    series.sort((a, b) => a.name.compareTo(b.name));

    // Create Program (FD Podcasts)
    return Program(
      name: 'FD Podcasts',
      description: podcast.description,
      imageUrl: podcast.imageUrl,
      series: series,
    );
  }

  String _getSeriesDescription(String seriesName) {
    final descriptions = {
      'FD Dagkoers': 'Dagkoers is de dagelijkse podcast van het FD. Binnen een kwartier word je door onze journalisten bijgepraat over wat er speelt in de wereld van het FD.',
      'FD-Gazellen': 'De FD-Gazellen podcast vertelt de verhalen van de snelst groeiende bedrijven van Nederland.',
      'FD Toegevoegde Waarde': 'FD Toegevoegde Waarde duikt dieper in economische en financiële onderwerpen.',
    };
    return descriptions[seriesName] ?? '';
  }

  String _parseDescription(String htmlDescription) {
    // Remove HTML tags and decode HTML entities
    String cleaned = htmlDescription
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
    
    // Remove CDATA wrapper if present
    if (cleaned.startsWith('<![CDATA[') && cleaned.endsWith(']]>')) {
      cleaned = cleaned.substring(9, cleaned.length - 3).trim();
    }
    
    return cleaned;
  }
}

