import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../layout/app_layout.dart';
import '../models/media_album.dart';
import '../widgets/app_shell_background.dart';
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
    final pad = AppLayout.horizontalPadding(context);
    final video = isVideoAlbum || (album.items.isNotEmpty && album.items.first.isVideo);
    final countLabel = video
        ? '${album.items.length} ${album.items.length == 1 ? 'video' : 'videos'}'
        : '${album.items.length} tracks';

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AppShellBackground(
        child: SafeArea(
          bottom: false,
          child: AppLayout.constrainContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 12, pad, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(CupertinoIcons.chevron_back),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              album.title,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              countLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
                    itemCount: album.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, i) {
                      final item = album.items[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                          child: item.thumbnailBytes != null && video
                              ? ClipOval(
                                  child: Image.memory(
                                    item.thumbnailBytes!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  video ? CupertinoIcons.videocam_fill : CupertinoIcons.music_note_2,
                                  color: theme.colorScheme.primary,
                                ),
                        ),
                        title: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(item.duration, style: theme.textTheme.bodySmall),
                        onTap: () {
                          if (video || item.isVideo) {
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => VideoPlayerScreen(mediaItem: item),
                              ),
                            );
                          } else {
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => LocalPlayerScreen(
                                  mediaItem: item,
                                  playlist: album.items,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
