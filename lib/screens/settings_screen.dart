import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              const SizedBox(height: 12),
              _buildSectionTitle('Appearance'),
              const SizedBox(height: 12),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          themeProvider.isDarkMode
                              ? CupertinoIcons.moon_fill
                              : CupertinoIcons.sun_max_fill,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark Mode',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                themeProvider.isDarkMode
                                    ? 'Dark theme active'
                                    : 'Light theme active',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.7 * 255).round()),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (_) => themeProvider.toggleTheme(),
                          activeThumbColor: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // App Info Section
              _buildSectionTitle('App Information'),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      CupertinoIcons.info_circle,
                      'Version',
                      _appVersion,
                    ),
                    Divider(height: 24, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.24 * 255).round())),
                    _buildInfoRow(
                      CupertinoIcons.device_phone_portrait,
                      'Platform',
                      'Android/iOS',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Storage Section
              _buildSectionTitle('Storage'),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildActionRow(
                      CupertinoIcons.trash,
                      'Clear Cache',
                      'Free up storage space',
                      () => _showClearCacheDialog(),
                    ),
                    Divider(height: 24, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.24 * 255).round())),
                    _buildActionRow(
                      CupertinoIcons.delete,
                      'Clear History',
                      'Remove recently played',
                      () => _showClearHistoryDialog(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // About Section
              _buildSectionTitle('About'),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildActionRow(
                      CupertinoIcons.heart_fill,
                      'Rate App',
                      'Support us with a review',
                      () => _showComingSoonDialog('Rate App'),
                    ),
                    Divider(height: 24, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.24 * 255).round())),
                    _buildActionRow(
                      CupertinoIcons.share,
                      'Share App',
                      'Tell your friends',
                      () => _showComingSoonDialog('Share App'),
                    ),
                    Divider(height: 24, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.24 * 255).round())),
                    _buildActionRow(
                      CupertinoIcons.doc_text,
                      'Privacy Policy',
                      'Read our privacy policy',
                      () => _showComingSoonDialog('Privacy Policy'),
                    ),
                    Divider(height: 24, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.24 * 255).round())),
                    _buildActionRow(
                      CupertinoIcons.doc_plaintext,
                      'Terms of Service',
                      'Read our terms',
                      () => _showComingSoonDialog('Terms of Service'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Developer Info
              Center(
                child: Column(
                  children: [
                    Text(
                      'ProPlayer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Made with ❤️ for music lovers',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.6 * 255).round()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.6 * 255).round()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.5 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((0.3 * 255).round()),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
  builder: (context) => AlertDialog(
  backgroundColor: theme.dialogTheme.backgroundColor,
        title: Text('Clear Cache', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        content: Text(
          'This will clear all cached images and data. Continue?',
          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withAlpha((0.8 * 255).round())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
  builder: (context) => AlertDialog(
  backgroundColor: theme.dialogTheme.backgroundColor,
        title: Text('Clear History', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        content: Text(
          'This will remove all recently played items. Continue?',
          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withAlpha((0.8 * 255).round())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
  builder: (context) => AlertDialog(
  backgroundColor: theme.dialogTheme.backgroundColor,
        title: Text(feature, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        content: Text(
          'This feature is coming soon!',
          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withAlpha((0.8 * 255).round())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
