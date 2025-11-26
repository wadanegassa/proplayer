import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../widgets/media_card.dart';
import '../providers/home_provider.dart';
import 'video_player_screen.dart';
import 'local_player_screen.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? 40.0 : 20.0;
    final titleFontSize = isTablet ? 32.0 : 28.0;
    final subtitleFontSize = isTablet ? 16.0 : 14.0;
    
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ProPlayer',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineSmall?.color,
                              ),
                            ),
                            Text(
                              'Listen to your favorite music',
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color?.withAlpha((0.8 * 255).round()),
                                fontSize: subtitleFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings, color: theme.iconTheme.color),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 40 : 30),

                  // Search Bar
                  TextField(
                    onSubmitted: (query) {
                      if (query.isNotEmpty) {
                        // Navigate to unified search results
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultsScreen(query: query),
                          ),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search songs, artist...',
            prefixIcon:
              Icon(CupertinoIcons.search, color: theme.iconTheme.color?.withAlpha((0.6 * 255).round())),
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 40 : 30),

                  // Recently Played
                    if (provider.recentlyPlayed.isNotEmpty) ...[
                    Text(
                      'Recently Played',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.recentlyPlayed.length,
                        itemBuilder: (context, index) {
                          final item = provider.recentlyPlayed[index];
                          return MediaCard(
                            title: item.title,
                            subtitle: item.subtitle,
                            duration: item.duration,
                            imageUrl: item.thumbnail,
                          thumbnailBytes: item.thumbnailBytes,
                            showYouTubeIcon: !item.isLocal,
                            isVideo: item.isVideo,
                            onTap: () {
                              if (!item.isLocal) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VideoPlayerScreen(mediaItem: item),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // Random Browser Songs
                  Text(
                    'Explore More',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.randomMix.length,
                      itemBuilder: (context, index) {
                        final item = provider.randomMix[index];
                        return MediaCard(
                          title: item.title,
                          subtitle: item.subtitle,
                          duration: item.duration,
                          imageUrl: item.thumbnail,
                          thumbnailBytes: item.thumbnailBytes,
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
                  ),
                  const SizedBox(height: 30),

                  // Local File Songs
                  Text(
                    'Local Songs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (provider.localSongs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('No local songs found', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withAlpha((0.7 * 255).round()))),
                    )
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.localSongs.take(10).length,
                        itemBuilder: (context, index) {
                          final item = provider.localSongs[index];
                          return MediaCard(
                            title: item.title,
                            subtitle: item.subtitle,
                            duration: item.duration,
                            thumbnailBytes: item.thumbnailBytes,
                            isVideo: item.isVideo,
                            onTap: () {
                              // Navigate to player
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocalPlayerScreen(
                                    mediaItem: item,
                                    playlist: provider.localSongs,
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
            );
          },
        ),
      ),
    );
  }
}
