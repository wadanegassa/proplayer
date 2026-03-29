import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../layout/app_layout.dart';
import '../models/media_album.dart';
import '../widgets/media_card.dart';
import '../providers/library_provider.dart';
import '../models/media_item.dart';
import '../widgets/app_shell_background.dart';
import 'library_album_screen.dart';
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

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AppShellBackground(
        child: SafeArea(
          bottom: false,
          child: AppLayout.constrainContent(
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
                        _buildFoldersView(theme, provider),
                      ],
                    );
                  },
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final h = AppLayout.horizontalPadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(h, 16, h, 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.4 : 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  CupertinoIcons.music_albums_fill,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Library',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Consumer<LibraryProvider>(
                    builder: (context, provider, _) {
                      return Text(
                        '${provider.audioFiles.length} tracks · ${provider.videoFiles.length} videos · ${provider.audioAlbums.length + provider.videoAlbums.length} folders',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.45)),
                  borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search your collection',
              prefixIcon: const Icon(CupertinoIcons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(CupertinoIcons.clear, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    final h = AppLayout.horizontalPadding(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: h, vertical: 8),
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.35)),
      ),
      child: TabBar(
        controller: _tabController,
        splashBorderRadius: BorderRadius.circular(10),
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        labelStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
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

    final h = AppLayout.horizontalPadding(context);
    return LayoutBuilder(
      builder: (context, c) {
        var cross = 2;
        if (c.maxWidth > 520) cross = 3;
        if (c.maxWidth > 820) cross = 4;
        final ratio = cross >= 3 ? 0.72 : 0.75;
        return GridView.builder(
          padding: EdgeInsets.fromLTRB(h, 20, h, 120),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            childAspectRatio: ratio,
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
            'Scanning library…',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
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
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
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

  List<MediaAlbum> _filterAlbums(List<MediaAlbum> source) {
    if (_searchQuery.isEmpty) return source;
    return source.where((a) {
      if (a.title.toLowerCase().contains(_searchQuery)) return true;
      return a.items.any((t) => t.title.toLowerCase().contains(_searchQuery));
    }).toList();
  }

  Widget _buildFoldersView(ThemeData theme, LibraryProvider provider) {
    if (provider.isScanning && provider.audioAlbums.isEmpty && provider.videoFiles.isEmpty) {
      return _buildLoadingState();
    }

    final audioAlbums = _filterAlbums(provider.audioAlbums);
    final videoAlbums = _filterAlbums(provider.videoAlbums);

    if (audioAlbums.isEmpty && videoAlbums.isEmpty) {
      final message = _searchQuery.isNotEmpty
          ? 'No folders match "$_searchQuery"'
          : 'No folders found. Grant media access and scan, or add files on your device.';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              if (_searchQuery.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton.icon(
                    onPressed: () => provider.scanMedia(),
                    icon: const Icon(CupertinoIcons.refresh),
                    label: const Text('Scan library'),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final h = AppLayout.horizontalPadding(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(h, 12, h, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        if (audioAlbums.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              'Audio',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...audioAlbums.map((album) => _folderTile(theme, album, isVideo: false)),
          if (videoAlbums.isNotEmpty) const SizedBox(height: 20),
        ],
        if (videoAlbums.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              'Video',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...videoAlbums.map((album) => _folderTile(theme, album, isVideo: true)),
        ],
      ],
    );
  }

  Widget _folderTile(ThemeData theme, MediaAlbum album, {required bool isVideo}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.35 : 1,
          ),
          child: Icon(
            isVideo ? CupertinoIcons.videocam_fill : CupertinoIcons.folder_fill,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          album.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          isVideo
              ? '${album.items.length} ${album.items.length == 1 ? 'video' : 'videos'}'
              : '${album.items.length} tracks',
        ),
        trailing: Icon(CupertinoIcons.chevron_forward, color: theme.colorScheme.onSurface.withValues(alpha: 0.35)),
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (context) => LibraryAlbumScreen(album: album, isVideoAlbum: isVideo),
            ),
          );
        },
      ),
    );
  }
}
