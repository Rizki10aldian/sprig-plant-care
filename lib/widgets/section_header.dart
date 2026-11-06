import 'package:flutter/material.dart';
import 'package:sprig/theme/app_text.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppText.heading)),
          if (trailing != null) Text(trailing!, style: AppText.caption),
        ],
      ),
    );
  }
}
