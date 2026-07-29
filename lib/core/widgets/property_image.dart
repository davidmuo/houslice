import 'dart:io';

import 'package:flutter/material.dart';

import '../services/photo_service.dart';
import '../theme/app_colors.dart';

/// Listing image with rounded corners, loading placeholder and offline
/// fallback so the UI never breaks without connectivity.
///
/// Accepts both remote URLs and on-device file paths, so a photo just picked
/// from the gallery previews identically to one already published.
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
    if (url.isEmpty) return _rounded(_placeholder());

    // Photos stored inline in the Firestore document (free-plan fallback for
    // Cloud Storage) arrive as base64 data URIs.
    if (PhotoService.isInline(url)) {
      return _rounded(
        Image.memory(
          PhotoService.decodeInline(url),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        ),
      );
    }

    if (PhotoService.isLocal(url)) {
      return _rounded(
        Image.file(
          File(url),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        ),
      );
    }

    return _rounded(
      Image.network(
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

  Widget _rounded(Widget child) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(12),
      child: child,
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
