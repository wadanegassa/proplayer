# 🎵 ProPlayer

<p align="center">
  <img src="assets/icon/app_icon.png" alt="ProPlayer Logo" width="120"/>
</p>

<p align="center">
  <strong>A modern, feature-rich media player built with Flutter</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.9+-blue?logo=flutter" alt="Flutter 3.9+"/>
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?logo=dart" alt="Dart 3.0+"/>
  <img src="https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Linux%20|%20Windows%20|%20macOS-green" alt="Platforms"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License"/>
</p>

---

## 📖 Overview

**ProPlayer** is a comprehensive media player application that seamlessly combines local media playback with YouTube streaming capabilities. Built with Flutter for cross-platform compatibility, it offers a beautiful, modern UI with support for both light and dark themes.

Whether you're listening to your local music collection or streaming gospel music from YouTube, ProPlayer provides a unified, elegant experience across all your devices.

---

## ✨ Features

### 🎧 Audio & Video Playback
- **Local Media Support** - Play audio and video files from your device storage
- **YouTube Integration** - Stream and search YouTube videos directly within the app
- **Background Audio** - Continue listening even when the app is minimized
- **Mini Player** - Quick access controls while browsing your library

### 📚 Library Management
- **Smart Organization** - Automatically scan and organize your media files
- **Folder View** - Browse media by folder structure
- **Search Functionality** - Quickly find your favorite tracks
- **Tab Navigation** - Switch between audio and video content easily

### 🎨 User Interface
- **Modern Design** - Clean, intuitive interface with glassmorphism effects
- **Dark & Light Themes** - Choose your preferred viewing mode
- **Smooth Animations** - Fluid transitions and interactions
- **Responsive Layout** - Adapts to different screen sizes

### 🌍 Gospel Music Categories
- **Amharic Gospel** - Ethiopian worship songs
- **Oromo Gospel** - Faarfannaa Afaan Oromoo
- **English Gospel** - International worship music
- **Random Mix** - Curated mix of all categories

### ⚙️ Settings & Customization
- **Theme Toggle** - Switch between light/dark mode
- **Cache Management** - Clear cached data
- **History Control** - Manage playback history
- **App Information** - Version and about details

---

## 🛠️ Tech Stack

### Core Framework
| Technology | Purpose |
|------------|---------|
| **Flutter 3.9+** | Cross-platform UI framework |
| **Dart 3.0+** | Programming language |
| **Provider** | State management |

### Media & Playback
| Package | Purpose |
|---------|---------|
| `just_audio` | Audio playback engine |
| `just_audio_background` | Background audio service |
| `video_player` | Video playback |
| `chewie` | Video player UI controls |
| `youtube_player_flutter` | YouTube video embedding |
| `youtube_explode_dart` | YouTube data extraction |

### Device & Storage
| Package | Purpose |
|---------|---------|
| `photo_manager` | Media file scanning |
| `permission_handler` | Runtime permissions |
| `path_provider` | File system paths |
| `shared_preferences` | Local settings storage |

### UI & Design
| Package | Purpose |
|---------|---------|
| `google_fonts` | Custom typography |
| `google_nav_bar` | Navigation bar |
| `fluid_bottom_nav_bar` | Animated bottom navigation |
| `sliding_up_panel` | Sliding panel UI |

### Utilities
| Package | Purpose |
|---------|---------|
| `http` | Network requests |
| `package_info_plus` | App version info |

---

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point & permission handling
├── models/
│   └── media_item.dart       # Media data model
├── providers/
│   ├── audio_player_provider.dart
│   ├── browser_provider.dart
│   ├── home_provider.dart
│   ├── library_provider.dart
│   ├── player_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── browse_screen.dart
│   ├── home_screen.dart
│   ├── library_screen.dart
│   ├── local_player_screen.dart
│   ├── main_screen.dart
│   ├── player_screen.dart
│   ├── search_results_screen.dart
│   ├── settings_screen.dart
│   ├── video_list_screen.dart
│   ├── video_player.dart
│   └── video_player_screen.dart
├── services/
│   ├── audio_player_service.dart
│   ├── history_service.dart
│   ├── local_media_service.dart
│   ├── media_service.dart
│   └── youtube_service.dart
├── theme/
│   └── app_theme.dart
└── widgets/
    ├── custom_bottom_nav_bar.dart
    ├── glass_container.dart
    ├── media_card.dart
    ├── mini_player.dart
    └── mini_player_bar.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/proplayer.git
   cd proplayer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

---

## 📱 Supported Platforms

| Platform | Status |
|----------|--------|
| Android | ✅ Supported |
| iOS | ✅ Supported |
| Linux | ✅ Supported |
| Windows | ✅ Supported |
| macOS | ✅ Supported |
| Web | ⚠️ Limited |

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Wada Negassa**

- GitHub: [@wadanegassa](https://github.com/wadanegassa)

---

<p align="center">
  Made with ❤️ and Flutter
</p>
