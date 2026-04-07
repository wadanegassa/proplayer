import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/media_card.dart';
import '../providers/home_provider.dart';
import 'video_player_screen.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/beat_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).loadHomeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final horizontalPadding = 24.0;

    return Scaffold(
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // —— HEADER ————————————————————————————————————————————————
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 60, horizontalPadding, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Discover',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.search_rounded, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // —— TAB BAR ———————————————————————————————————————————————
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      dividerColor: Colors.transparent,
                      indicatorColor: AppTheme.primary,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelPadding: const EdgeInsets.only(right: 24),
                      labelColor: theme.colorScheme.onSurface,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      labelStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      unselectedLabelStyle: theme.textTheme.titleMedium,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Songs'),
                        Tab(text: 'Albums'),
                        Tab(text: 'Artists'),
                      ],
                    ),
                  ),
                ),
              ),

              // —— POPULAR THIS WEEK ——————————————————————————————————————
              if (provider.randomMix.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      _SectionHeader(title: 'Popular This Week', padding: horizontalPadding),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(left: horizontalPadding),
                          itemCount: provider.randomMix.length,
                          itemBuilder: (context, index) {
                            final item = provider.randomMix[index];
                            return MediaCard(
                              title: item.title,
                              subtitle: item.subtitle,
                              imageUrl: item.thumbnail,
                              duration: item.duration,
                              isVideo: true,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(mediaItem: item),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // —— TOP SONGS ——————————————————————————————————————————————
              if (provider.recentlyPlayed.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 16),
                    child: _SectionHeader(title: 'Top Songs', padding: horizontalPadding),
                  ),
                ),
              
              if (provider.recentlyPlayed.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = provider.recentlyPlayed[index];
                        final audioProvider = context.watch<AudioPlayerProvider>();
                        final isPlaying = audioProvider.isPlaying && audioProvider.currentTrack?.id == item.id;
                        
                        return _SongTile(
                          item: item,
                          isPlaying: isPlaying,
                          onTap: () {
                            if (!item.isLocal) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(mediaItem: item),
                                ),
                              );
                            } else {
                              audioProvider.playTrack(item, provider.recentlyPlayed);
                            }
                          },
                        );
                      },
                      childCount: provider.recentlyPlayed.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.padding});
  final String title;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  const _SongTile({required this.item, required this.onTap, this.isPlaying = false});
  final dynamic item;
  final VoidCallback onTap;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Thumbnail with play icon
            BeatAnimation(
              isPlaying: isPlaying,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.thumbnail != null
                        ? Image.network(item.thumbnail!, width: 56, height: 56, fit: BoxFit.cover)
                        : item.thumbnailBytes != null
                            ? Image.memory(item.thumbnailBytes!, width: 56, height: 56, fit: BoxFit.cover)
                            : Container(
                                width: 56, 
                                height: 56, 
                                color: isPlaying ? AppTheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surface,
                                child: Icon(Icons.graphic_eq_rounded, color: isPlaying ? AppTheme.primary : Colors.grey),
                              ),
                  ),
                  Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 24),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPlaying ? AppTheme.primary : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.subtitle} • 12,098 Played',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
