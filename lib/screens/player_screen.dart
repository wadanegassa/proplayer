import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/media_model.dart';

class PlayerScreen extends StatelessWidget {
  final MediaModel song;
  const PlayerScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(song.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 120, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(song.title, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            if (player.isPlaying)
              IconButton(
                icon: const Icon(Icons.pause_circle, size: 70),
                onPressed: player.pause,
              )
            else
              IconButton(
                icon: const Icon(Icons.play_circle, size: 70),
                onPressed: () => player.play(song),
              ),
          ],
        ),
      ),
    );
  }
}
