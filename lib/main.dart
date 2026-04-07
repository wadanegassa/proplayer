import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/home_provider.dart';
import 'providers/browser_provider.dart';
import 'providers/library_provider.dart';
import 'providers/audio_player_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/main_nav_provider.dart';
import 'services/media_service.dart';
import 'package:photo_manager/photo_manager.dart';
import 'theme/app_theme.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.proplayer.channel.audio',
    androidNotificationChannelName: 'ProPlayer',
    androidNotificationOngoing: true,
  );

  final audioPlayerProvider = AudioPlayerProvider();
  audioPlayerProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => BrowserProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider.value(value: audioPlayerProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MainNavProvider()),
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
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? AppTheme.pageDark
                : AppTheme.pageLight,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading…',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isGranted) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? AppTheme.pageDark
                : AppTheme.pageLight,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: theme.brightness == Brightness.dark ? 0.35 : 1,
                      ),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.35)),
                    ),
                    child: Icon(
                      Icons.folder_special_rounded,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Media access',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(height: 1.1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Allow ProPlayer to read audio & video on your device for the Library tab and local playback. You can still browse and play YouTube without this.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      height: 1.45,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _isGranted = true),
                    child: const Text('Continue without library'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () async {
                      final mediaService = MediaService();
                      final hasPermission = await mediaService.requestPermission();
                      if (hasPermission) {
                        setState(() => _isGranted = true);
                      } else {
                        await PhotoManager.openSetting();
                      }
                    },
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Text('Grant access'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => PhotoManager.openSetting(),
                    child: const Text('Open system settings'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const MainScreen();
  }
}
