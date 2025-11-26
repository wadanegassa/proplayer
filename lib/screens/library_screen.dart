import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
// app_theme removed; prefer Theme.of(context) where needed
import '../widgets/media_card.dart';
import '../providers/library_provider.dart';
import '../models/media_item.dart';
import 'local_player_screen.dart';
import 'video_player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Efficiently schedule scan after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<LibraryProvider>(context, listen: false);
        // Only scan if empty to avoid unnecessary re-scans on tab switch
        if (provider.audioFiles.isEmpty && provider.videoFiles.isEmpty) {
          provider.scanMedia();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to handle responsiveness at the screen level if needed,
    // but here we mainly need it for the grid.
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildCompactHeader(),
            _buildTabBar(),
            Expanded(
              child: Consumer<LibraryProvider>(
                builder: (context, provider, _) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMediaGrid(provider, isVideo: false),
                      _buildMediaGrid(provider, isVideo: true),
                      _buildFoldersView(),
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

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          // Top Row: Title & Stats
          Row(
            children: [
              // Title Section
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withAlpha(72),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.music_albums_fill,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        'Library',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineSmall?.color,
                        ),
                      ),
                    Consumer<LibraryProvider>(
                      builder: (context, provider, _) {
                        return Text(
                          '${provider.audioFiles.length} Songs • ${provider.videoFiles.length} Videos',
                          style: TextStyle(
                             color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.6 * 255).round()),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Refresh Action
              Consumer<LibraryProvider>(
                builder: (context, provider, _) {
                    return IconButton(
                    icon: provider.isScanning
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : Icon(CupertinoIcons.refresh, color: Theme.of(context).textTheme.bodySmall?.color),
                    onPressed: provider.isScanning
                        ? null
                        : () => provider.scanMedia(),
                    tooltip: 'Rescan Library',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search Bar
          SizedBox(
            height: 40,
              child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              decoration: InputDecoration(
                hintText: 'Search songs, videos...',
                  hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.4 * 255).round())),
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.4 * 255).round()),
                    size: 18,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface.withAlpha(15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(CupertinoIcons.clear, color: Theme.of(context).colorScheme.onSurface.withAlpha(179), size: 16),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 36,
      decoration: BoxDecoration(
  color: Theme.of(context).colorScheme.surface.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Theme.of(context).colorScheme.onPrimary,
  unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.8 * 255).round()),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Audio'),
          Tab(text: 'Videos'),
          Tab(text: 'Folders'),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(LibraryProvider provider, {required bool isVideo}) {
    if (provider.isScanning && provider.audioFiles.isEmpty && provider.videoFiles.isEmpty) {
      return _buildLoadingState();
    }

    final items = isVideo ? provider.videoFiles : provider.audioFiles;
    
    // Filter items based on search query
    final filteredItems = _searchQuery.isEmpty
        ? items
        : items.where((item) {
            return item.title.toLowerCase().contains(_searchQuery) ||
                   item.subtitle.toLowerCase().contains(_searchQuery);
          }).toList();

    if (filteredItems.isEmpty) {
      return _buildEmptyState(isVideo);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive column count
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }

        return RefreshIndicator(
          onRefresh: () => provider.scanMedia(),
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).cardColor,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.8, // Taller cards as requested
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return MediaCard(
                title: item.title,
                subtitle: item.subtitle,
                duration: item.duration,
                thumbnailBytes: item.thumbnailBytes,
                isVideo: item.isVideo,
                useDynamicSizing: false,
                onTap: () => _handleMediaTap(context, item, filteredItems),
              );
            },
          ),
        );
      },
    );
  }

  void _handleMediaTap(BuildContext context, MediaItem item, List<MediaItem> playlist) {
    if (item.isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(mediaItem: item),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocalPlayerScreen(
            mediaItem: item,
            playlist: playlist,
          ),
        ),
      );
    }
  }

  Widget _buildLoadingState() {
    return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
           Text(
             'Scanning Library...',
             style: TextStyle(
               color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179),
               fontSize: 16,
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isVideo) {
    final message = _searchQuery.isNotEmpty
        ? 'No results found for "$_searchQuery"'
        : 'No ${isVideo ? 'videos' : 'songs'} found';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVideo ? Icons.videocam_off : CupertinoIcons.music_note_list,
            size: 64,
             color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
               color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha((0.6 * 255).round()),
              fontSize: 16,
            ),
          ),
          if (_searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  Provider.of<LibraryProvider>(context, listen: false).scanMedia();
                },
                icon: const Icon(CupertinoIcons.refresh),
                label: const Text('Scan Again'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFoldersView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
               color: Theme.of(context).colorScheme.surface.withAlpha((0.05 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.folder,
              size: 48,
               color: Theme.of(context).colorScheme.onSurface.withAlpha((0.54 * 255).round()),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Folder View',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
               color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse by folders coming soon',
            style: TextStyle(
              fontSize: 14,
               color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.5 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }
}
