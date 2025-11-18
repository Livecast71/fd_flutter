import 'package:shared_preferences/shared_preferences.dart';

enum DownloadQuality {
  high(128, 'Hoog (128 kbps)', 'Best quality, larger file size'),
  medium(98, 'Gemiddeld (98 kbps)', 'Good balance of quality and size'),
  low(64, 'Laag (64 kbps)', 'Smaller file size, lower quality');

  final int bitrate;
  final String displayName;
  final String description;

  const DownloadQuality(this.bitrate, this.displayName, this.description);
}

class DownloadQualityService {
  static const String _qualityPreferenceKey = 'download_quality_preference';
  static const DownloadQuality _defaultQuality = DownloadQuality.medium;

  /// Get the current download quality preference
  Future<DownloadQuality> getDownloadQuality() async {
    final prefs = await SharedPreferences.getInstance();
    final qualityIndex = prefs.getInt(_qualityPreferenceKey);
    
    if (qualityIndex != null && qualityIndex >= 0 && qualityIndex < DownloadQuality.values.length) {
      return DownloadQuality.values[qualityIndex];
    }
    
    return _defaultQuality;
  }

  /// Set the download quality preference
  Future<void> setDownloadQuality(DownloadQuality quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_qualityPreferenceKey, quality.index);
  }

  /// Get all available quality options
  List<DownloadQuality> getAvailableQualities() {
    return DownloadQuality.values;
  }

  /// Get default quality
  DownloadQuality getDefaultQuality() => _defaultQuality;

  /// Estimate file size in MB for a given duration (in seconds) and quality
  double estimateFileSize(int durationSeconds, DownloadQuality quality) {
    // Formula: (bitrate in kbps * duration in seconds) / (8 * 1024) = size in MB
    // This is approximate as actual file size depends on encoding efficiency
    return (quality.bitrate * durationSeconds) / (8 * 1024);
  }

  /// Format estimated file size
  String formatEstimatedSize(int durationSeconds, DownloadQuality quality) {
    final sizeMB = estimateFileSize(durationSeconds, quality);
    if (sizeMB < 1) {
      return '${(sizeMB * 1024).toStringAsFixed(0)} KB';
    }
    return '${sizeMB.toStringAsFixed(1)} MB';
  }
}

