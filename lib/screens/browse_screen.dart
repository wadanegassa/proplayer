import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure we have random mix loaded
      Provider.of<HomeProvider>(context, listen: false).loadHomeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // New
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Search
                  Container(
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
                      controller: _searchController,
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
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Search gospel songs...',
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
                  const SizedBox(height: 40),

                  // Categories
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Gospel Categories',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryCard(
                    context,
                    'Amharic Gospel',
                    '150+ songs',
                    theme.brightness == Brightness.dark ? AppTheme.deepBlueGradient : AppTheme.morningMistGradient,
                    Icons.music_note_rounded,
                    () => _navigateToCategory(context, 'Amharic Gospel'),
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    context,
                    'Afaan Oromo Gospel',
                    '120+ songs',
                    theme.brightness == Brightness.dark ? AppTheme.oceanBreezeGradient : AppTheme.softBlueGradient,
                    Icons.library_music_rounded,
                    () => _navigateToCategory(context, 'Afaan Oromo Gospel'),
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    context,
                    'English Gospel',
                    '200+ songs',
                    theme.brightness == Brightness.dark ? AppTheme.purpleHazeGradient : AppTheme.softPinkGradient,
                    Icons.album_rounded,
                    () => _navigateToCategory(context, 'English Gospel'),
                    theme,
                  ),
                  const SizedBox(height: 40),

                  // Random Picks
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Random Picks',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Consumer<HomeProvider>(
                    builder: (context, homeProvider, _) {
                      if (homeProvider.randomMix.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return SizedBox(
                        height: 240,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: homeProvider.randomMix.length,
                          itemBuilder: (context, index) {
                            final item = homeProvider.randomMix[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: MediaCard(
                                title: item.title,
                                subtitle: item.subtitle,
                                duration: item.duration,
                                thumbnailBytes: item.thumbnailBytes,
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
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
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
    BuildContext context,
    String title,
    String subtitle,
    LinearGradient gradient,
    IconData icon,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final iconColor = isDark ? Colors.white : theme.colorScheme.primary;
    final iconBgColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white;

    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: textColor.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: textColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
