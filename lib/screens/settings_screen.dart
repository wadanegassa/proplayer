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
  String _appVersion = '…';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _appVersion = '1.0.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.brightness == Brightness.dark ? AppTheme.pageDark : AppTheme.pageLight,
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              floating: false,
              pinned: true,
              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.72),
              surfaceTintColor: Colors.transparent,
              title: Text('Settings', style: theme.textTheme.titleLarge),
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (b) => AppTheme.accentGradient.createShader(b),
                            child: Text(
                              'PRO',
                              style: theme.textTheme.labelLarge?.copyWith(
                                letterSpacing: 5,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Studio',
                            style: theme.textTheme.headlineMedium?.copyWith(height: 1.05),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('Appearance', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return GlassContainer(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: theme.colorScheme.secondary.withValues(alpha: 0.18),
                              ),
                              child: Icon(
                                themeProvider.isDarkMode
                                    ? CupertinoIcons.moon_stars_fill
                                    : CupertinoIcons.sun_max_fill,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dark appearance',
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    themeProvider.isDarkMode ? 'OLED-friendly ink & coral' : 'Warm paper & daylight',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (_) => themeProvider.toggleTheme(),
                              thumbColor: WidgetStateProperty.resolveWith(
                                (s) => s.contains(WidgetState.selected)
                                    ? theme.colorScheme.onPrimary
                                    : null,
                              ),
                              trackColor: WidgetStateProperty.resolveWith(
                                (s) => s.contains(WidgetState.selected)
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text('App', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Column(
                      children: [
                        _InfoRow(icon: CupertinoIcons.info_circle, label: 'Version', value: _appVersion),
                        Divider(height: 1, color: theme.dividerTheme.color),
                        _InfoRow(icon: CupertinoIcons.device_phone_portrait, label: 'Platform', value: 'Mobile'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Data', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Column(
                      children: [
                        _ActionRow(
                          icon: CupertinoIcons.trash_circle,
                          title: 'Clear cache',
                          subtitle: 'Free temporary storage',
                          onTap: _showClearCacheDialog,
                        ),
                        Divider(height: 1, color: theme.dividerTheme.color),
                        _ActionRow(
                          icon: CupertinoIcons.clock_fill,
                          title: 'Clear history',
                          subtitle: 'Recently played list',
                          onTap: _showClearHistoryDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Support', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Column(
                      children: [
                        _ActionRow(
                          icon: CupertinoIcons.heart_fill,
                          title: 'Rate ProPlayer',
                          subtitle: 'On the store',
                          onTap: () => _showComingSoon('Rate'),
                        ),
                        Divider(height: 1, color: theme.dividerTheme.color),
                        _ActionRow(
                          icon: CupertinoIcons.share_up,
                          title: 'Share',
                          subtitle: 'Invite a friend',
                          onTap: () => _showComingSoon('Share'),
                        ),
                        Divider(height: 1, color: theme.dividerTheme.color),
                        _ActionRow(
                          icon: CupertinoIcons.doc_text_fill,
                          title: 'Privacy',
                          onTap: () => _showComingSoon('Privacy'),
                        ),
                        Divider(height: 1, color: theme.dividerTheme.color),
                        _ActionRow(
                          icon: CupertinoIcons.doc_plaintext,
                          title: 'Terms',
                          onTap: () => _showComingSoon('Terms'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Text('ProPlayer', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                          'Crafted for listening sessions.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear cache', style: theme.textTheme.titleLarge),
        content: Text(
          'Remove cached thumbnails and temp data?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
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
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear history', style: theme.textTheme.titleLarge),
        content: Text(
          'Remove all recently played items?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(feature, style: theme.textTheme.titleLarge),
        content: Text('Coming soon.', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}
