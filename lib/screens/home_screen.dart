import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/media_card.dart';
import '../widgets/app_shell_background.dart';
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? 40.0 : 20.0;
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
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 28, horizontalPadding, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) =>
                                      AppTheme.accentGradient.createShader(bounds),
                                  child: Text(
                                    'PRO',
                                    style: GoogleFonts.sora(
                                      fontSize: isTablet ? 14 : 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 4,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Player',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontSize: isTablet ? 40 : 34,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Local tracks & streaming in one studio.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                    height: 1.35,
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

                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 28, horizontalPadding, 0),
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
                        decoration: InputDecoration(
                          hintText: 'Search artists, titles, albums…',
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: theme.colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface.withValues(
                            alpha: theme.brightness == Brightness.dark ? 0.5 : 0.95,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 36)),

                  if (provider.recentlyPlayed.isNotEmpty) ...[
                    _sectionHeader(context, 'Recently played', horizontalPadding),
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

                  _sectionHeader(context, 'Explore', horizontalPadding),
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

                  _sectionHeader(context, 'On this device', horizontalPadding),
                  if (provider.localSongs.isEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                            color: theme.colorScheme.surface.withValues(alpha: 0.35),
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
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.74,
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
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, double padding) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: EdgeInsets.only(left: padding, right: padding, bottom: 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(
              width: 5,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: AppTheme.accentGradient,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.45),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(fontSize: 22),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
              child: Row(
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
      color: theme.colorScheme.surface.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: theme.colorScheme.onSurface, size: 22),
        ),
      ),
    );
  }
}
