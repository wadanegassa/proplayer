import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/media_card.dart';
import '../widgets/app_shell_background.dart';
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
      Provider.of<HomeProvider>(context, listen: false).loadHomeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AppShellBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Curated gospel channels & search.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _searchController,
                  onSubmitted: (query) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BrowserResultsScreen(category: 'Search: $query'),
                      ),
                    );
                    Provider.of<BrowserProvider>(context, listen: false).search(query);
                  },
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search gospel, worship, hymns…',
                    prefixIcon: Icon(CupertinoIcons.search, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withValues(
                      alpha: isDark ? 0.5 : 0.95,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'Categories',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _CategoryCard(
                  title: 'Amharic Gospel',
                  subtitle: '150+ songs',
                  gradient: isDark ? AppTheme.categorySunset : AppTheme.categorySunsetSoft,
                  icon: Icons.music_note_rounded,
                  onTap: () => _navigateToCategory(context, 'Amharic Gospel'),
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _CategoryCard(
                  title: 'Afaan Oromo Gospel',
                  subtitle: '120+ songs',
                  gradient: isDark ? AppTheme.categoryOcean : AppTheme.categoryOceanSoft,
                  icon: Icons.library_music_rounded,
                  onTap: () => _navigateToCategory(context, 'Afaan Oromo Gospel'),
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _CategoryCard(
                  title: 'English Gospel',
                  subtitle: '200+ songs',
                  gradient: isDark ? AppTheme.categoryViolet : AppTheme.categoryVioletSoft,
                  icon: Icons.album_rounded,
                  onTap: () => _navigateToCategory(context, 'English Gospel'),
                  isDark: isDark,
                ),
                const SizedBox(height: 36),
                Text(
                  'Random picks',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Consumer<HomeProvider>(
                  builder: (context, homeProvider, _) {
                    if (homeProvider.randomMix.isEmpty) {
                      return SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
                      );
                    }
                    return SizedBox(
                      height: 244,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: homeProvider.randomMix.length,
                        itemBuilder: (context, index) {
                          final item = homeProvider.randomMix[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 14),
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
                                    builder: (context) => VideoPlayerScreen(mediaItem: item),
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
                const SizedBox(height: 110),
              ],
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
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onGradient = isDark ? Colors.white : AppTheme.inkBody;
    final iconBg = isDark ? Colors.white.withValues(alpha: 0.16) : Colors.white;

    return Material(
      color: Colors.transparent,
      child: Ink(
        height: 112,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: isDark ? 0.35 : 0.2),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -24,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.45),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(icon, color: isDark ? Colors.white : theme.colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: onGradient,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: onGradient.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_rounded, color: onGradient, size: 20),
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
