import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layout/app_layout.dart';
import '../providers/browser_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/app_shell_background.dart';
import '../widgets/media_card.dart';
import 'local_player_screen.dart';
import 'video_player_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BrowserProvider>(context, listen: false).search(widget.query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = widget.query.toLowerCase();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '"${widget.query}"',
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: AppShellBackground(
        child: AppLayout.constrainContent(
          child: Consumer2<LibraryProvider, BrowserProvider>(
            builder: (context, libraryProvider, browserProvider, _) {
              final localAudio = libraryProvider.audioFiles
                  .where(
                    (item) =>
                        item.title.toLowerCase().contains(q) ||
                        item.subtitle.toLowerCase().contains(q),
                  )
                  .toList();
              final localVideo = libraryProvider.videoFiles
                  .where(
                    (item) =>
                        item.title.toLowerCase().contains(q) ||
                        item.subtitle.toLowerCase().contains(q),
                  )
                  .toList();

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.horizontalPadding(context),
                      16,
                      AppLayout.horizontalPadding(context),
                      24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (localAudio.isNotEmpty) ...[
                          Text(
                            'On device · Audio',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: localAudio.length,
                              itemBuilder: (context, index) {
                                final item = localAudio[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: MediaCard(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    duration: item.duration,
                                    thumbnailBytes: item.thumbnailBytes,
                                    isVideo: false,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (context) => LocalPlayerScreen(
                                            mediaItem: item,
                                            playlist: localAudio,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                        if (localVideo.isNotEmpty) ...[
                          Text(
                            'On device · Video',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: localVideo.length,
                              itemBuilder: (context, index) {
                                final item = localVideo[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: MediaCard(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    duration: item.duration,
                                    thumbnailBytes: item.thumbnailBytes,
                                    isVideo: true,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (context) => VideoPlayerScreen(mediaItem: item),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                        Text(
                          'Online',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        if (browserProvider.state == BrowserState.loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (browserProvider.state == BrowserState.error)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(Icons.cloud_off_outlined, size: 48, color: theme.colorScheme.outline),
                                const SizedBox(height: 12),
                                Text(
                                  'Couldn’t load YouTube results. Check your connection and try again.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () => browserProvider.search(widget.query),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        else if (browserProvider.videos.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Text(
                                  localAudio.isEmpty && localVideo.isEmpty
                                      ? 'No matches on your device or YouTube for this search.'
                                      : 'No YouTube videos for this search.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () => browserProvider.search(widget.query),
                                  child: const Text('Search again'),
                                ),
                              ],
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: browserProvider.videos.length,
                            itemBuilder: (context, index) {
                              final item = browserProvider.videos[index];
                              return MediaCard(
                                title: item.title,
                                subtitle: item.subtitle,
                                duration: item.duration,
                                imageUrl: item.thumbnail,
                                showYouTubeIcon: true,
                                isVideo: true,
                                useDynamicSizing: false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) => VideoPlayerScreen(mediaItem: item),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
