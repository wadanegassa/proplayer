import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/music_list_screen.dart';
import 'providers/player_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: const ProPlayer(),
    ),
  );
}

class ProPlayer extends StatelessWidget {
  const ProPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProPlayer',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      home: const MusicListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
