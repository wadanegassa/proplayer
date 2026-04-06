import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_widgets.dart';
import '../models/media_album.dart';
import 'local_player_screen.dart';
import 'video_player_screen.dart';

class LibraryAlbumScreen extends StatelessWidget {
  const LibraryAlbumScreen({
    super.key,
    required this.album,
    this.isVideoAlbum = false,
  });

  final MediaAlbum album;
  final bool isVideoAlbum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final video = isVideoAlbum || (album.items.isNotEmpty && album.items.first.isVideo);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // —— HEADER ———————————————————————————————————————————————
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  NeumorphicButton(
                    size: 44,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${album.items.length} ${video ? "videos" : "tracks"}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // —— LIST —————————————————————————————————————————————————
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                itemCount: album.items.length,
                itemBuilder: (context, i) {
                  final item = album.items[i];
                  return NeumorphicListTile(
                    title: item.title,
                    subtitle: item.duration,
                    onTap: () {
                      if (video || item.isVideo) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(mediaItem: item)));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LocalPlayerScreen(mediaItem: item, playlist: album.items)));
                      }
                    },
                    trailing: const Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white24),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
