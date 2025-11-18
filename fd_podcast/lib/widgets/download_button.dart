import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../services/download_service.dart';

class DownloadButton extends StatefulWidget {
  final Episode episode;
  final VoidCallback? onDownloadComplete;

  const DownloadButton({
    super.key,
    required this.episode,
    this.onDownloadComplete,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  final DownloadService _downloadService = DownloadService();
  bool _isDownloaded = false;
  bool _isDownloading = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await _downloadService.isDownloaded(widget.episode.guid);
    setState(() {
      _isDownloaded = isDownloaded;
      _isLoading = false;
    });
  }

  Future<void> _downloadEpisode() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      await _downloadService.downloadEpisode(widget.episode);
      setState(() {
        _isDownloaded = true;
        _isDownloading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download voltooid'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      widget.onDownloadComplete?.call();
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download mislukt: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteDownload() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download verwijderen?'),
        content: const Text('Weet je zeker dat je deze download wilt verwijderen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verwijderen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _downloadService.deleteDownload(widget.episode.guid);
      if (success) {
        setState(() {
          _isDownloaded = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download verwijderd'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_isDownloading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_isDownloaded) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.download_done, color: Colors.green, size: 20),
        onSelected: (value) {
          if (value == 'delete') {
            _deleteDownload();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Verwijderen'),
              ],
            ),
          ),
        ],
        tooltip: 'Gedownload - tik voor opties',
      );
    }

    return IconButton(
      icon: const Icon(Icons.download, size: 20),
      onPressed: _downloadEpisode,
      tooltip: 'Download voor offline luisteren',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

