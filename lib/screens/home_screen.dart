import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_widgets.dart';
import '../widgets/media_card.dart';
import '../providers/home_provider.dart';
import 'video_player_screen.dart';

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
    final theme = Theme.of(context);
    final isTablet = MediaQuery.sizeOf(context).width > 600;
    final horizontalPadding = isTablet ? 32.0 : 20.0;

    return Scaffold(
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.brand));
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // —— NEUMORPHIC HEADER ——————————————————————————————————————
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.background,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 60, horizontalPadding, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'PROPLAYER',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.brand,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Discover',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        NeumorphicButton(
                          size: 48,
                          onPressed: () {},
                          child: const Icon(Icons.search_rounded, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // —— TRENDING (EXPLORE) —————————————————————————————————————
              if (provider.randomMix.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'Trending Now', padding: horizontalPadding),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 240,
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

              // —— RECENTLY PLAYED ————————————————————————————————————————
              if (provider.recentlyPlayed.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(title: 'Recently Played', padding: 0),
                  ),
                ),
              
              if (provider.recentlyPlayed.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = provider.recentlyPlayed[index];
                        return NeumorphicListTile(
                          title: item.title,
                          subtitle: item.subtitle,
                          isSelected: index == 0,
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
                          trailing: NeumorphicButton(
                            size: 32,
                            borderRadius: 8,
                            onPressed: () {},
                            child: const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white70),
                          ),
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
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
