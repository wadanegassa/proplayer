import 'package:flutter/material.dart';

class MediaTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MediaTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.music_note, color: Colors.deepPurple),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
