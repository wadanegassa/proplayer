import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_widgets.dart';
import '../widgets/media_card.dart';
import '../providers/library_provider.dart';
import 'library_album_screen.dart';
import 'local_player_screen.dart';
import 'video_player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LibraryProvider>(context, listen: false);
      if (provider.audioFiles.isEmpty && provider.videoFiles.isEmpty) {
        provider.scanMedia();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final horizontalPadding = MediaQuery.sizeOf(context).width > 600 ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // —— HEADER ———————————————————————————————————————————————
            Padding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 40, horizontalPadding, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.brand,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Library',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<LibraryProvider>(
                    builder: (context, provider, _) => NeumorphicButton(
                      size: 48,
                      onPressed: provider.isScanning ? null : () => provider.scanMedia(),
                      child: provider.isScanning
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
                          : const Icon(Icons.refresh_rounded, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            // —— SEARCH ———————————————————————————————————————————————
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: NeumorphicContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                borderRadius: 20,
                depth: -6,
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search your collection...',
                    hintStyle: TextStyle(color: Colors.white24),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // —— TABS —————————————————————————————————————————————————
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: NeumorphicContainer(
                height: 54,
                borderRadius: 20,
                padding: const EdgeInsets.all(6),
                depth: -4,
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.brand,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: AppTheme.brand.withValues(alpha: 0.3), blurRadius: 8),
                    ],
                  ),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelColor: Colors.white38,
                  tabs: const [
                    Tab(text: 'Audio'),
                    Tab(text: 'Videos'),
                    Tab(text: 'Folders'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // —— TAB CONTENT ———————————————————————————————————————————
            Expanded(
              child: Consumer<LibraryProvider>(
                builder: (context, provider, _) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMediaGrid(provider, isVideo: false),
                      _buildMediaGrid(provider, isVideo: true),
                      _buildFoldersView(provider),
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

  Widget _buildMediaGrid(LibraryProvider provider, {required bool isVideo}) {
    final items = isVideo ? provider.videoFiles : provider.audioFiles;
    final filtered = items.where((i) => i.title.toLowerCase().contains(_searchQuery)).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No items found', style: TextStyle(color: Colors.white24)));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return MediaCard(
          title: item.title,
          subtitle: item.subtitle,
          thumbnailBytes: item.thumbnailBytes,
          isVideo: item.isVideo,
          onTap: () {
            if (item.isVideo) {
               Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(mediaItem: item)));
            } else {
               Navigator.push(context, MaterialPageRoute(builder: (context) => LocalPlayerScreen(mediaItem: item, playlist: filtered)));
            }
          },
        );
      },
    );
  }

  Widget _buildFoldersView(LibraryProvider provider) {
    // Basic folder implementation using NeumorphicListTile
    final folders = [...provider.audioAlbums, ...provider.videoAlbums];
    final filtered = folders.where((f) => f.title.toLowerCase().contains(_searchQuery)).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final folder = filtered[index];
        return NeumorphicListTile(
          title: folder.title,
          subtitle: '${folder.items.length} items',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LibraryAlbumScreen(album: folder, isVideoAlbum: folder.items.isNotEmpty && folder.items.first.isVideo))),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white24),
        );
      },
    );
  }
}
