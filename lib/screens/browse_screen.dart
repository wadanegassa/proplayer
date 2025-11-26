import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
// theme import removed; use Theme.of(context) instead
import '../widgets/media_card.dart';
import '../providers/browser_provider.dart';
import '../providers/home_provider.dart';
import 'browser_results_screen.dart';
import 'video_player_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure we have random mix loaded
      Provider.of<HomeProvider>(context, listen: false).loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(CupertinoIcons.globe,
                      color: theme.colorScheme.secondary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Browse Online',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
                    onPressed: () {
                      // Trigger refresh
                      final browserProvider = Provider.of<BrowserProvider>(context, listen: false);
                      browserProvider.resetToDefault();
                      
                      // Refresh random mix
                      Provider.of<HomeProvider>(context, listen: false).loadHomeData();

                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search
              TextField(
                onSubmitted: (query) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BrowserResultsScreen(category: 'Search: $query'),
                    ),
                  );
                  // Trigger search in provider if needed, but results screen handles fetching
                  Provider.of<BrowserProvider>(context, listen: false).search(query);
                },
                decoration: InputDecoration(
                  hintText: 'Search gospel songs...',
                  prefixIcon: Icon(CupertinoIcons.search, color: theme.hintColor),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Categories
              Text(
                'Gospel Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                'Amharic Gospel',
                '150+ songs',
                [const Color(0xFF8B5CF6), const Color(0xFFC026D3)],
                () => _navigateToCategory(context, 'Amharic Gospel'),
              ),
              const SizedBox(height: 12),
              _buildCategoryCard(
                'Afaan Oromo Gospel',
                '120+ songs',
                [const Color(0xFF0284C7), const Color(0xFF0891B2)],
                () => _navigateToCategory(context, 'Afaan Oromo Gospel'),
              ),
              const SizedBox(height: 12),
              _buildCategoryCard(
                'English Gospel',
                '200+ songs',
                [const Color(0xFFEA580C), const Color(0xFFDC2626)],
                () => _navigateToCategory(context, 'English Gospel'),
              ),
              const SizedBox(height: 30),

              // Random Picks
              Text(
                'Random Picks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<HomeProvider>(
                builder: (context, homeProvider, _) {
                  if (homeProvider.randomMix.isEmpty) {
            return const Center(child: CircularProgressIndicator());
                  }
                  return SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: homeProvider.randomMix.length,
                      itemBuilder: (context, index) {
                        final item = homeProvider.randomMix[index];
                        return MediaCard(
                          title: item.title,
                          subtitle: item.subtitle,
                          duration: item.duration,
                          imageUrl: item.thumbnail,
                          showYouTubeIcon: true,
                          isVideo: true,
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowserResultsScreen(category: category),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    String subtitle,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onPrimary.withAlpha(204),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 16,
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
