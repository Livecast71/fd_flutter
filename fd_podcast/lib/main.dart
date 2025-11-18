import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Dutch locale
  await initializeDateFormatting('nl_NL', null);
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const FDPodcastApp());
}

class FDPodcastApp extends StatefulWidget {
  const FDPodcastApp({super.key});

  @override
  State<FDPodcastApp> createState() => _FDPodcastAppState();
}

class _FDPodcastAppState extends State<FDPodcastApp> {
  final ThemeService _themeService = ThemeService();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await _themeService.getMaterialThemeMode();
    setState(() {
      _themeMode = themeMode;
    });
  }

  void _updateThemeMode() {
    _loadThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FD Podcast',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(onThemeChanged: _updateThemeMode),
    );
  }
}
