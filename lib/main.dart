import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/music_list_screen.dart';
import 'providers/player_provider.dart';
import 'services/media_service.dart';
import 'package:photo_manager/photo_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PlayerProvider())],
      child: const ProPlayer(),
    ),
  );
}

class ProPlayer extends StatelessWidget {
  const ProPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ProPlayer',
      theme: ThemeData.dark(),
      home: const PermissionHandlerScreen(),
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
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_off, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Permission Required',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Allow storage/media access to load your music and videos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
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
                icon: const Icon(Icons.settings),
                label: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Permission granted — go to main music list
    return const MusicListScreen();
  }
}
