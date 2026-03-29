import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../layout/app_layout.dart';
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
          child: AppLayout.constrainContent(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(AppLayout.horizontalPadding(context), 24,
                  AppLayout.horizontalPadding(context), 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.35 : 1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.explore_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discover',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              height: 1.05,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Search and browse curated gospel channels.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  onSubmitted: (query) {
                    if (query.trim().isEmpty) return;
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
                  decoration: const InputDecoration(
                    hintText: 'Search gospel, worship, hymns…',
                    prefixIcon: Icon(CupertinoIcons.search),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Categories',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
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
                const SizedBox(height: 28),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Random picks',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 92,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: isDark ? Colors.white : theme.colorScheme.primary, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: onGradient,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onGradient.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: onGradient.withValues(alpha: 0.7), size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
