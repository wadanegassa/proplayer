import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/media_card.dart';
import '../providers/home_provider.dart';
import '../theme/app_theme.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.surface,
                    const Color(0xFF1E1B4B), // Deep indigo
                    theme.scaffoldBackgroundColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.4, 1.0],
                )
              : AppTheme.morningMistGradient,
        ),
        child: Stack(
          children: [
            // Ambient background glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Consumer<HomeProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Modern App Bar
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ProPlayer',
                                    style: GoogleFonts.outfit(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurface,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  Text(
                                    'Your premium music experience',
                                    style: GoogleFonts.outfit(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      fontSize: subtitleFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface),
                                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Search Bar
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                  blurRadius: 25,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: TextField(
                              onSubmitted: (query) {
                                if (query.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchResultsScreen(query: query),
                                    ),
                                  );
                                }
                              },
                              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Search songs, artists, albums...',
                                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(CupertinoIcons.search, color: theme.colorScheme.primary),
                                ),
                                filled: true,
                                fillColor: theme.cardColor.withValues(alpha: 0.8),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 40)),

                      // Recently Played
                      if (provider.recentlyPlayed.isNotEmpty) ...[
                        _buildSectionHeader('Recently Played', horizontalPadding),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 240,
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding - 8),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: provider.recentlyPlayed.length,
                              itemBuilder: (context, index) {
                                final item = provider.recentlyPlayed[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: MediaCard(
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
                                            builder: (context) => VideoPlayerScreen(mediaItem: item),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],

                      // Explore More
                      _buildSectionHeader('Explore More', horizontalPadding),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 240,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding - 8),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: provider.randomMix.length,
                            itemBuilder: (context, index) {
                              final item = provider.randomMix[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: MediaCard(
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
                                        builder: (context) => VideoPlayerScreen(mediaItem: item),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),

                      // Local Songs
                      _buildSectionHeader('Local Songs', horizontalPadding),
                      if (provider.localSongs.isEmpty)
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'No local songs found',
                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final song = provider.localSongs[index];
                                return MediaCard(
                                  title: song.title,
                                  subtitle: song.subtitle,
                                  duration: song.duration,
                                  thumbnailBytes: song.thumbnailBytes,
                                  isVideo: song.isVideo,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LocalPlayerScreen(
                                          mediaItem: song,
                                          playlist: provider.localSongs,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              childCount: provider.localSongs.length,
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 120)), // Space for bottom nav
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double padding) {
    return SliverPadding(
      padding: EdgeInsets.only(left: padding, right: padding, bottom: 20),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                children: [
                  const Text(
                    'See All',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
