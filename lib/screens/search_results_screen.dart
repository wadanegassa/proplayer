import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_widgets.dart';
import '../widgets/media_card.dart';
import '../providers/browser_provider.dart';
import '../providers/library_provider.dart';
import 'local_player_screen.dart';
import 'video_player_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BrowserProvider>(context, listen: false).search(widget.query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = widget.query.toLowerCase();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // —— HEADER ———————————————————————————————————————————————
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  NeumorphicButton(
                    size: 44,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SEARCHING FOR',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.brand,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          '"${widget.query}"',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // —— CONTENT ——————————————————————————————————————————————
            Expanded(
              child: Consumer2<LibraryProvider, BrowserProvider>(
                builder: (context, library, browser, _) {
                  final localAudio = library.audioFiles.where((i) => i.title.toLowerCase().contains(q)).toList();
                  final localVideo = library.videoFiles.where((i) => i.title.toLowerCase().contains(q)).toList();

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      if (localAudio.isNotEmpty || localVideo.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                            child: _SectionHeader('On Device'),
                          ),
                        ),
                      
                      if (localAudio.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 24,
                              childAspectRatio: 0.85,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = localAudio[index];
                                return MediaCard(
                                  title: item.title,
                                  subtitle: item.subtitle,
                                  thumbnailBytes: item.thumbnailBytes,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LocalPlayerScreen(mediaItem: item, playlist: localAudio))),
                                );
                              },
                              childCount: localAudio.length,
                            ),
                          ),
                        ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                          child: _SectionHeader('Online Results'),
                        ),
                      ),

                      if (browser.state == BrowserState.loading)
                        const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.brand))),

                      if (browser.videos.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 24,
                              childAspectRatio: 0.85,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = browser.videos[index];
                                return MediaCard(
                                  title: item.title,
                                  subtitle: item.subtitle,
                                  imageUrl: item.thumbnail,
                                  showYouTubeIcon: true,
                                  isVideo: true,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(mediaItem: item))),
                                );
                              },
                              childCount: browser.videos.length,
                            ),
                          ),
                        ),
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
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
    );
  }
}
