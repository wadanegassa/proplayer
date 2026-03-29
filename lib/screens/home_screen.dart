import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../layout/app_layout.dart';
import '../widgets/media_card.dart';
import '../widgets/app_shell_background.dart';
import '../widgets/glass_container.dart';
import '../providers/home_provider.dart';
import '../providers/main_nav_provider.dart';
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = AppLayout.isTabletWidth(screenWidth);
    final horizontalPadding = AppLayout.horizontalPadding(context);
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AppShellBackground(
        child: SafeArea(
          bottom: false,
          child: Consumer<HomeProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading your library…',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return AppLayout.constrainContent(
                child: RefreshIndicator(
                  onRefresh: () => context.read<HomeProvider>().refreshHomeData(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
                    sliver: SliverToBoxAdapter(
                      child: GlassContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PROPLAYER',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Your music',
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      fontSize: isTablet ? 36 : 30,
                                      height: 1.05,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Local files and online discovery in one place.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _IconChipButton(
                              icon: Icons.tune_rounded,
                              onPressed: () => Navigator.pushNamed(context, '/settings'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
                    sliver: SliverToBoxAdapter(
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
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search artists, titles, albums…',
                          prefixIcon: Icon(CupertinoIcons.search),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  if (provider.recentlyPlayed.isNotEmpty) ...[
                    _sectionHeader(
                      context,
                      'Recently played',
                      horizontalPadding,
                      onSeeAll: () => context.read<MainNavProvider>().setIndex(2),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 244,
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
                    const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  ],

                  _sectionHeader(
                    context,
                    'Explore',
                    horizontalPadding,
                    onSeeAll: () => context.read<MainNavProvider>().setIndex(1),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 244,
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
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  _sectionHeader(
                    context,
                    'On this device',
                    horizontalPadding,
                    onSeeAll: () => context.read<MainNavProvider>().setIndex(2),
                  ),
                  if (provider.localSongs.isEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.45),
                            ),
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.audio_file_outlined,
                                size: 40,
                                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'No local audio yet. Grant media access or add files and pull to refresh in Library.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverLayoutBuilder(
                      builder: (context, constraints) {
                        var cross = 2;
                        if (constraints.crossAxisExtent > 520) cross = 3;
                        if (constraints.crossAxisExtent > 820) cross = 4;
                        final ratio = cross >= 3 ? 0.72 : 0.74;
                        return SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cross,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: ratio,
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
                        );
                      },
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
            );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title,
    double padding, {
    VoidCallback? onSeeAll,
  }) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: EdgeInsets.only(left: padding, right: padding, bottom: 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('All', style: theme.textTheme.labelLarge),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IconChipButton extends StatelessWidget {
  const _IconChipButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.65)),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          ),
          child: Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.85), size: 22),
        ),
      ),
    );
  }
}
