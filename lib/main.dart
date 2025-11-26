import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/player_provider.dart';
import 'providers/home_provider.dart';
import 'providers/browser_provider.dart';
import 'providers/library_provider.dart';
import 'providers/audio_player_provider.dart';
import 'providers/theme_provider.dart';
import 'services/media_service.dart';
import 'package:photo_manager/photo_manager.dart';
import 'theme/app_theme.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AudioPlayerProvider
  final audioPlayerProvider = AudioPlayerProvider();
  audioPlayerProvider.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => BrowserProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider.value(value: audioPlayerProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const ProPlayer(),
    ),
  );
}

class ProPlayer extends StatelessWidget {
  const ProPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ProPlayer',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const PermissionHandlerScreen(),
          routes: {
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

/// Handles storage/media permission safely before opening the music list
class PermissionHandlerScreen extends StatefulWidget {
  const PermissionHandlerScreen({super.key});

  @override
  State<PermissionHandlerScreen> createState() =>
      _PermissionHandlerScreenState();
}

class _PermissionHandlerScreenState extends State<PermissionHandlerScreen> {
  bool _isLoading = true;
  bool _isGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final mediaService = MediaService();
    final hasPermission = await mediaService.requestPermission();
    setState(() {
      _isGranted = hasPermission;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isGranted) {
      final theme = Theme.of(context);
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off, size: 80, color: theme.iconTheme.color),
              const SizedBox(height: 20),
              Text(
                'Permission Required',
                style: TextStyle(fontSize: 20, color: theme.textTheme.headlineSmall?.color),
              ),
              const SizedBox(height: 10),
              Text(
                'Allow storage/media access to load your music and videos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withAlpha((0.8 * 255).round())),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: () async {
                  final mediaService = MediaService();
                  final hasPermission = await mediaService.requestPermission();
                  if (hasPermission) {
                    setState(() => _isGranted = true);
                  } else {
                    // Open settings if permission denied
                    await PhotoManager.openSetting();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                icon: Icon(Icons.settings, color: theme.colorScheme.onPrimary),
                label: Text('Grant Permission', style: TextStyle(color: theme.colorScheme.onPrimary)),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Permission granted — go to main screen
    return const MainScreen();
  }
}
