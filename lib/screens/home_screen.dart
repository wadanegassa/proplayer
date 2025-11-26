import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
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
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Listen to your favorite music',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: subtitleFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.settings, color: Colors.white),
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
                          const Icon(CupertinoIcons.search, color: Colors.grey),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 40 : 30),

                  // Recently Played
                  if (provider.recentlyPlayed.isNotEmpty) ...[
                    const Text(
                      'Recently Played',
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
                  const Text(
                    'Random Mix',
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
                  const Text(
                    'Local Songs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (provider.localSongs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text('No local songs found', style: TextStyle(color: Colors.grey)),
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
