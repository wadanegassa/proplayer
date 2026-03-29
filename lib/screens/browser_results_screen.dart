import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layout/app_layout.dart';
import '../widgets/app_shell_background.dart';
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
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
      body: AppShellBackground(
        child: AppLayout.constrainContent(
          child: Consumer<BrowserProvider>(
            builder: (context, provider, child) {
              if (provider.state == BrowserState.loading) {
                return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
              }

              if (provider.state == BrowserState.error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_outlined, color: theme.colorScheme.outline, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Couldn’t load videos',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check your connection and try again.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () => provider.fetchCategory(widget.category),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (provider.videos.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          'No videos found',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try another category or pull to refresh later.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () => provider.fetchCategory(widget.category),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
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
                        MaterialPageRoute<void>(
                          builder: (context) => VideoPlayerScreen(mediaItem: item),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
