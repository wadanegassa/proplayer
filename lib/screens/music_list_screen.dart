import 'package:flutter/material.dart';
import 'package:proplayer/widgets/midea_tile.dart';
import '../services/media_service.dart';
import '../models/media_model.dart';
import 'player_screen.dart';

class MusicListScreen extends StatefulWidget {
  const MusicListScreen({super.key});

  @override
  State<MusicListScreen> createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  List<MediaModel> _audios = [];

  @override
  void initState() {
    super.initState();
    loadAudios();
  }

  Future<void> loadAudios() async {
    final result = await MediaService.getAllAudios();
    setState(() => _audios = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ProPlayer – Music")),
      body: _audios.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _audios.length,
              itemBuilder: (context, index) {
                final song = _audios[index];
                return MediaTile(
                  title: song.title,
                  subtitle: "${song.duration.inMinutes}:${(song.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(song: song),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
