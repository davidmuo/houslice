import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Playful empty state matching the "Opps!!" illustration screens in the
/// Figma design, drawn with icons so no image assets are required.
class EmptyState extends StatelessWidget {
  final String? header;
  final IconData icon;
  final String title;
  final Widget? subtitle;

  const EmptyState({
    super.key,
    this.header,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (header != null) ...[
              Text(
                header!,
                style: GoogleFonts.caveat(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                color: AppColors.primaryFaint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 72, color: AppColors.primary),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              DefaultTextStyle(
                style: textTheme.bodyMedium!.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
                child: subtitle!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
