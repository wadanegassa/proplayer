import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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
    final isVideo = isVideoAlbum || (album.items.isNotEmpty && album.items.first.isVideo);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // —— HEADER ———————————————————————————————————————————————
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                   IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVideo ? 'VIDEO FOLDER' : 'AUDIO ALBUM',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                        Text(
                          album.title,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 150),
                itemCount: album.items.length,
                itemBuilder: (context, i) {
                  final item = album.items[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item.duration),
                      onTap: () {
                        if (isVideo || item.isVideo) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(mediaItem: item)));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LocalPlayerScreen(mediaItem: item, playlist: album.items)));
                        }
                      },
                      trailing: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primary, size: 28),
                    ),
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
