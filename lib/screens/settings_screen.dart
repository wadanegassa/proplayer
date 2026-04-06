import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_widgets.dart';
import '../providers/home_provider.dart';
import '../services/history_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '1.0.0';

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
          _appVersion = packageInfo.version;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final horizontalPadding = MediaQuery.sizeOf(context).width > 600 ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // —— HEADER ———————————————————————————————————————————————
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 40, horizontalPadding, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREFERENCES',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.brand,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Settings',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // —— SECTIONS —————————————————————————————————————————————
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),
                  _buildSectionHeader('Account & Data'),
                  NeumorphicContainer(
                    padding: const EdgeInsets.all(8),
                    borderRadius: 24,
                    depth: 8,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.history_rounded,
                          title: 'Clear History',
                          onTap: _showClearHistoryDialog,
                        ),
                        _SettingsTile(
                          icon: Icons.delete_sweep_rounded,
                          title: 'Clear Cache',
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache cleared'))),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Support'),
                  NeumorphicContainer(
                    padding: const EdgeInsets.all(8),
                    borderRadius: 24,
                    depth: 8,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.star_outline_rounded,
                          title: 'Rate App',
                          onTap: () {},
                        ),
                        _SettingsTile(
                          icon: Icons.share_rounded,
                          title: 'Invite Friends',
                          // ignore: deprecated_member_use
                          onTap: () => Share.share('Check out ProPlayer!'),
                        ),
                        _SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'ProPlayer v$_appVersion',
                          style: const TextStyle(color: Colors.white24, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Made with ❤️ for Gospel Music',
                          style: TextStyle(color: Colors.white10, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear your recently played history?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await HistoryService().clearAll();
              if (mounted) {
                context.read<HomeProvider>().loadHomeData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History cleared')));
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.darkShadow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.brand, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
    );
  }
}
