import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/media_card.dart';
import '../providers/library_provider.dart';
import '../providers/browser_provider.dart';
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
      // Trigger online search
      Provider.of<BrowserProvider>(context, listen: false).search(widget.query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search: "${widget.query}"',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Local Results
            Consumer<LibraryProvider>(
              builder: (context, libraryProvider, _) {
                final localResults = libraryProvider.audioFiles
                    .where((item) =>
                        item.title.toLowerCase().contains(widget.query.toLowerCase()) ||
                        item.subtitle.toLowerCase().contains(widget.query.toLowerCase()))
                    .toList();

                if (localResults.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Local Songs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: localResults.length,
                        itemBuilder: (context, index) {
                          final item = localResults[index];
                          return MediaCard(
                            title: item.title,
                            subtitle: item.subtitle,
                            duration: item.duration,
                            thumbnailBytes: item.thumbnailBytes,
                            isVideo: item.isVideo,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocalPlayerScreen(
                                    mediaItem: item,
                                    playlist: localResults,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),

            // Online Results
            Consumer<BrowserProvider>(
              builder: (context, browserProvider, _) {
                if (browserProvider.state == BrowserState.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (browserProvider.state == BrowserState.error) {
                  return const Center(
                    child: Text(
                      'Failed to load online results',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                if (browserProvider.videos.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Online Results',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoPlayerScreen(mediaItem: item),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
