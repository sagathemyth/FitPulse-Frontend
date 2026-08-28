import 'package:flutter/material.dart';

/// A simple, license-free "illustration" for empty states — a soft
/// gradient halo behind an icon, in the app's own brand color. Used
/// instead of stock photography so there's no sourcing/licensing risk,
/// while still giving empty states more visual warmth than a bare
/// grey icon.
class EmptyStateIllustration extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;

  const EmptyStateIllustration({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withOpacity(0.25), color.withOpacity(0.05)],
                ),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}
