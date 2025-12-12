import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// removed app_theme import; using Theme.of(context)
import '../widgets/media_card.dart';
import '../providers/browser_provider.dart';
import 'video_player_screen.dart';

class BrowserResultsScreen extends StatefulWidget {
  final String category;

  const BrowserResultsScreen({super.key, required this.category});

  @override
  State<BrowserResultsScreen> createState() => _BrowserResultsScreenState();
}

class _BrowserResultsScreenState extends State<BrowserResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BrowserProvider>(context, listen: false)
          .fetchCategory(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category,
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<BrowserProvider>(context, listen: false)
                  .fetchCategory(widget.category);
            },
          ),
        ],
      ),
      body: Consumer<BrowserProvider>(
        builder: (context, provider, child) {
          if (provider.state == BrowserState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

            if (provider.state == BrowserState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Failed to load videos', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(179))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchCategory(widget.category),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.videos.length,
            itemBuilder: (context, index) {
              final item = provider.videos[index];
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
          );
        },
      ),
    );
  }
}
