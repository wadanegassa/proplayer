import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
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
      Provider.of<BrowserProvider>(context, listen: false).fetchCategory(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                          widget.category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Search Results',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Provider.of<BrowserProvider>(context, listen: false).fetchCategory(widget.category),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),

            // —— CONTENT ——————————————————————————————————————————————
            Expanded(
              child: Consumer<BrowserProvider>(
                builder: (context, provider, child) {
                  if (provider.state == BrowserState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.videos.isEmpty) {
                    return Center(
                      child: Text('No results found', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 150),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: provider.videos.length,
                    itemBuilder: (context, index) {
                      final item = provider.videos[index];
                      return MediaCard(
                        title: item.title,
                        subtitle: item.subtitle,
                        imageUrl: item.thumbnail,
                        showYouTubeIcon: true,
                        isVideo: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(mediaItem: item),
                          ),
                        ),
                      );
                    },
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
