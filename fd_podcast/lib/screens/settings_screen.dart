import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/download_quality_service.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  
  const SettingsScreen({super.key, this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DownloadQualityService _qualityService = DownloadQualityService();
  final ThemeService _themeService = ThemeService();
  
  AppThemeMode _currentThemeMode = AppThemeMode.system;
  DownloadQuality _currentQuality = DownloadQuality.medium;
  String _appVersion = 'Laden...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await _themeService.getThemeMode();
    final quality = await _qualityService.getDownloadQuality();
    final packageInfo = await PackageInfo.fromPlatform();
    
    setState(() {
      _currentThemeMode = themeMode;
      _currentQuality = quality;
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      _isLoading = false;
    });
  }

  Future<void> _changeThemeMode(AppThemeMode newMode) async {
    await _themeService.setThemeMode(newMode);
    setState(() {
      _currentThemeMode = newMode;
    });
    
    // Notify parent to rebuild with new theme
    widget.onThemeChanged?.call();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thema gewijzigd naar ${_themeService.getThemeModeDisplayName(newMode)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _changeQuality(DownloadQuality newQuality) async {
    await _qualityService.setDownloadQuality(newQuality);
    setState(() {
      _currentQuality = newQuality;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Standaard download kwaliteit: ${newQuality.displayName}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Instellingen'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instellingen'),
      ),
      body: ListView(
        children: [
          // Theme Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Weergave',
              style: theme.textTheme.titleLarge,
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Thema'),
                  subtitle: Text(_themeService.getThemeModeDisplayName(_currentThemeMode)),
                  trailing: PopupMenuButton<AppThemeMode>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: _changeThemeMode,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: AppThemeMode.light,
                        child: Row(
                          children: [
                            Icon(
                              Icons.light_mode,
                              color: _currentThemeMode == AppThemeMode.light
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            const Text('Licht'),
                            if (_currentThemeMode == AppThemeMode.light)
                              const SizedBox(width: 8),
                            if (_currentThemeMode == AppThemeMode.light)
                              Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: AppThemeMode.dark,
                        child: Row(
                          children: [
                            Icon(
                              Icons.dark_mode,
                              color: _currentThemeMode == AppThemeMode.dark
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            const Text('Donker'),
                            if (_currentThemeMode == AppThemeMode.dark)
                              const SizedBox(width: 8),
                            if (_currentThemeMode == AppThemeMode.dark)
                              Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: AppThemeMode.system,
                        child: Row(
                          children: [
                            Icon(
                              Icons.brightness_auto,
                              color: _currentThemeMode == AppThemeMode.system
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            const Text('Systeem'),
                            if (_currentThemeMode == AppThemeMode.system)
                              const SizedBox(width: 8),
                            if (_currentThemeMode == AppThemeMode.system)
                              Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Download Settings Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Downloads',
              style: theme.textTheme.titleLarge,
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Standaard Download Kwaliteit'),
                  subtitle: Text(_currentQuality.description),
                  trailing: PopupMenuButton<DownloadQuality>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: _changeQuality,
                    itemBuilder: (context) => DownloadQuality.values.map((quality) {
                      return PopupMenuItem(
                        value: quality,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(quality.displayName),
                                  Text(
                                    quality.description,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (_currentQuality == quality)
                              const SizedBox(width: 8),
                            if (_currentQuality == quality)
                              Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // App Info Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'App Informatie',
              style: theme.textTheme.titleLarge,
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Versie'),
              subtitle: Text(_appVersion),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

