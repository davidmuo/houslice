import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Network image with rounded corners, loading placeholder and offline
/// fallback so the UI never breaks without connectivity.
class PropertyImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BorderRadius? radius;
  final BoxFit fit;

  const PropertyImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(12),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(),
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: AppColors.surface,
        alignment: Alignment.center,
        child: const Icon(Icons.home_rounded, color: AppColors.grey, size: 32),
      );
}
