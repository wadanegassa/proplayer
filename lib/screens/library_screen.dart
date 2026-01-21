import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/media_card.dart';
import '../providers/library_provider.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<LibraryProvider>(context, listen: false);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.surface,
                    const Color(0xFF1E1B4B), // Deep indigo
                    theme.scaffoldBackgroundColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.4, 1.0],
                )
              : AppTheme.morningMistGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(theme),
              _buildTabBar(theme),
              Expanded(
                child: Consumer<LibraryProvider>(
                  builder: (context, provider, _) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMediaGrid(provider, isVideo: false),
                        _buildMediaGrid(provider, isVideo: true),
                        _buildFoldersView(theme),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  CupertinoIcons.music_albums_fill,
                  color: theme.colorScheme.tertiary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Library',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Consumer<LibraryProvider>(
                    builder: (context, provider, _) {
                      return Text(
                        '${provider.audioFiles.length} Songs • ${provider.videoFiles.length} Videos',
                        style: GoogleFonts.outfit(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Consumer<LibraryProvider>(
                  builder: (context, provider, _) {
                    return IconButton(
                      icon: provider.isScanning
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onSurface,
                              ),
                            )
                          : Icon(Icons.refresh, color: theme.colorScheme.onSurface),
                      onPressed: provider.isScanning
                          ? null
                          : () => provider.scanMedia(),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search your collection...',
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(CupertinoIcons.search, color: theme.colorScheme.tertiary),
                ),
                filled: true,
                fillColor: theme.cardColor.withValues(alpha: 0.8),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.colorScheme.tertiary, width: 1.5),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(CupertinoIcons.clear, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
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

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 15,
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
    
    final filteredItems = _searchQuery.isEmpty
        ? items
        : items.where((item) {
            return item.title.toLowerCase().contains(_searchQuery) ||
                   item.subtitle.toLowerCase().contains(_searchQuery);
          }).toList();

    if (filteredItems.isEmpty) {
      return _buildEmptyState(isVideo);
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
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
            style: GoogleFonts.outfit(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVideo ? Icons.videocam_off_outlined : CupertinoIcons.music_note_list,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.outfit(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
          if (_searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextButton.icon(
                onPressed: () {
                  Provider.of<LibraryProvider>(context, listen: false).scanMedia();
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.tertiary,
                ),
                icon: const Icon(CupertinoIcons.refresh),
                label: const Text('Scan Again'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFoldersView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.folder,
              size: 64,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Folder View',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse by folders coming soon',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
