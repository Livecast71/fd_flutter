# FD Podcast

A modern Flutter podcast application for listening to and managing podcast episodes. Built with Flutter, this app provides a seamless experience for discovering, playing, downloading, and organizing your favorite podcast content.

## 📱 Features

- **Podcast Discovery**: Browse and explore podcasts from RSS feeds
- **Audio Playback**: High-quality audio playback with background support
- **Download Management**: Download episodes for offline listening
- **Favorites**: Save your favorite episodes for quick access
- **Follow Series**: Follow podcast series to stay updated
- **Smart Alerts**: Get notified about new episodes automatically
  - **FD Dagkoers Alerts**: Automatic alerts for FD Dagkoers episodes published before 16:00
  - **Followed Podcast Alerts**: Notifications for new episodes in your followed series
- **Search**: Search through episodes and content
- **Modern UI**: Clean and intuitive Material Design interface
- **Multi-platform**: Supports iOS, Android, Web, macOS, Linux, and Windows

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.10.0 or higher)
- iOS: Xcode 13.0+ (for iOS development)
- Android: Android Studio with Android SDK (for Android development)
- CocoaPods 1.16.2+ (for iOS dependencies)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Livecast71/fd_flutter.git
   cd fd_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Install iOS dependencies** (iOS only)
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### Core Dependencies
- `flutter` - Flutter SDK
- `http` (^1.2.0) - HTTP client for fetching RSS feeds
- `xml` (^6.4.2) - XML parsing for RSS feeds
- `intl` (^0.19.0) - Internationalization and date formatting
- `shared_preferences` (^2.2.2) - Local data persistence

### Audio & Media
- `just_audio` (^0.9.36) - Audio playback functionality
- `audio_service` (^0.18.11) - Background audio service
- `path_provider` (^2.1.1) - File system paths for downloads

### Permissions
- `permission_handler` (^11.3.0) - Handle device permissions

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── episode.dart         # Episode model
│   ├── podcast.dart         # Podcast model
│   ├── program.dart         # Program model
│   └── series.dart          # Series model
├── screens/                  # App screens
│   ├── home_screen.dart     # Home screen
│   ├── main_tab_screen.dart # Main tab navigation
│   ├── downloads_screen.dart
│   ├── favorites_screen.dart
│   ├── followed_screen.dart
│   ├── programs_screen.dart
│   ├── series_screen.dart
│   └── episode_detail_screen.dart
├── services/                 # Business logic services
│   ├── rss_service.dart     # RSS feed parsing
│   ├── audio_player_service.dart
│   ├── download_service.dart
│   ├── favorites_service.dart
│   ├── followed_service.dart
│   ├── dagkoers_alert_service.dart  # FD Dagkoers alert functionality
│   └── followed_alert_service.dart  # Followed podcast alert functionality
├── widgets/                  # Reusable widgets
│   ├── audio_player_widget.dart
│   ├── mini_player_widget.dart
│   ├── episode_card.dart
│   ├── series_card.dart
│   ├── dagkoers_alert_dialog.dart      # FD Dagkoers alert dialog
│   ├── new_episode_alert_dialog.dart  # Followed podcast alert dialog
│   └── ...
└── theme/                    # App theming
    └── app_theme.dart
```

## 🔧 Building

### iOS

1. **Install CocoaPods dependencies**
   ```bash
   cd ios
   pod install
   cd ..
   ```

2. **Build for iOS**
   ```bash
   flutter build ios
   ```

   Or open `ios/Runner.xcworkspace` in Xcode and build from there.

### Android

1. **Build for Android**
   ```bash
   flutter build apk
   ```

   Or open the project in Android Studio and build from there.

### Web

```bash
flutter build web
```

## 📱 Platform Requirements

- **iOS**: Minimum deployment target iOS 12.0 (configured for iOS 13.0)
- **Android**: Minimum SDK version 21 (Android 5.0)
- **Flutter**: 3.10.0+

## 🎨 Features in Detail

### Audio Playback
- Background audio playback
- Lock screen controls
- Audio session management
- Playback controls (play, pause, seek, volume)

### Downloads
- Download episodes for offline listening
- Manage downloaded content
- Storage management

### Organization
- Organize podcasts by programs and series
- Follow series for updates
- Mark episodes as favorites
- Search functionality

### Smart Alerts

The app includes intelligent alert functionality to keep you informed about new podcast episodes:

#### FD Dagkoers Alerts
- **Automatic Detection**: The app automatically checks for new FD Dagkoers episodes published before 16:00 (4:00 PM)
- **Date & Time Validation**: Only alerts for episodes published on the current day before the cutoff time
- **One-Time Alerts**: Each episode is only alerted once to avoid duplicate notifications
- **Direct Navigation**: Tap the alert to go directly to the episode detail screen

#### Followed Podcast Alerts
- **Track New Episodes**: Automatically tracks which episodes you've seen for each followed series
- **Smart Detection**: Compares the latest episode with your last seen episode to detect new content
- **Multiple Alerts**: Shows alerts for all followed series with new episodes (shown sequentially)
- **Seen Tracking**: Episodes are marked as seen when you view them or dismiss the alert
- **First-Time Handling**: When you first follow a series, the latest episode is automatically marked as seen (no initial alert)

#### How Alerts Work
1. **On App Launch**: The app checks for new episodes when you open it
2. **Priority System**: FD Dagkoers alerts are shown first (if available), followed by followed podcast alerts
3. **Sequential Display**: Multiple alerts are shown one at a time to avoid overwhelming the user
4. **Persistent Tracking**: Your viewing history is stored locally using SharedPreferences
5. **Smart Navigation**: Tap "Bekijk aflevering" to go directly to the episode, or "Later" to dismiss

#### Alert Services
- **DagkoersAlertService**: Handles FD Dagkoers-specific alert logic and tracking
- **FollowedAlertService**: Manages episode tracking for followed series and detects new episodes

## 🛠️ Development

### Running in Debug Mode
```bash
flutter run
```

### Running in Release Mode
```bash
flutter run --release
```

### Running on Specific Device
```bash
flutter devices                    # List available devices
flutter run -d <device-id>        # Run on specific device
```

### Code Analysis
```bash
flutter analyze
```

### Running Tests
```bash
flutter test
```

## 📝 Configuration

### RSS Feed
The RSS feed URL can be configured in `lib/services/rss_service.dart`:
```dart
static const String rssUrl = 'YOUR_RSS_FEED_URL';
```

### App Theme
Customize the app theme in `lib/theme/app_theme.dart`.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is private and not published to pub.dev.

## 👤 Author

**Livecast71**
- GitHub: [@Livecast71](https://github.com/Livecast71)

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Audio playback powered by [just_audio](https://pub.dev/packages/just_audio)
- RSS parsing with [xml](https://pub.dev/packages/xml)

---

**Note**: This project requires Flutter 3.10.0+ and Dart 3.10.0+. Make sure you have the latest stable version of Flutter installed before running the project.
