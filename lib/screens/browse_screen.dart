import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_widgets.dart';
import '../widgets/media_card.dart';
import '../providers/home_provider.dart';
import '../providers/browser_provider.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.sizeOf(context).width > 600;
    final horizontalPadding = isTablet ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // —— HEADER ———————————————————————————————————————————————
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 40, horizontalPadding, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BROWSE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.brand,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Categories',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // —— SEARCH BAR ———————————————————————————————————————————
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: NeumorphicContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: 20,
                  depth: -6, // Recessed for input
                  child: TextField(
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
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Search gospel, worship, hymns…',
                      hintStyle: TextStyle(color: Colors.white24),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.white54),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            // —— CATEGORIES ———————————————————————————————————————————
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 32, horizontalPadding, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                ),
                delegate: SliverChildListDelegate([
                  _CategoryItem(
                    title: 'Amharic',
                    icon: Icons.music_note_rounded,
                    onTap: () => _navigateToCategory(context, 'Amharic Gospel'),
                  ),
                  _CategoryItem(
                    title: 'Oromo',
                    icon: Icons.library_music_rounded,
                    onTap: () => _navigateToCategory(context, 'Afaan Oromo Gospel'),
                  ),
                  _CategoryItem(
                    title: 'English',
                    icon: Icons.album_rounded,
                    onTap: () => _navigateToCategory(context, 'English Gospel'),
                  ),
                  _CategoryItem(
                    title: 'Worship',
                    icon: Icons.auto_awesome_rounded,
                    onTap: () => _navigateToCategory(context, 'Worship'),
                  ),
                ]),
              ),
            ),

            // —— TOP PICKS —————————————————————————————————————————————
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 40, horizontalPadding, 20),
                child: Text(
                  'Top Picks',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Consumer<HomeProvider>(
                builder: (context, homeProvider, _) {
                  if (homeProvider.randomMix.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.brand));
                  }
                  return SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(left: horizontalPadding),
                      physics: const BouncingScrollPhysics(),
                      itemCount: homeProvider.randomMix.length,
                      itemBuilder: (context, index) {
                        final item = homeProvider.randomMix[index];
                        return MediaCard(
                          title: item.title,
                          subtitle: item.subtitle,
                          imageUrl: item.thumbnail,
                          isVideo: true,
                          showYouTubeIcon: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(mediaItem: item),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
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

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.title, required this.icon, required this.onTap});
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        depth: 8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.brand, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
