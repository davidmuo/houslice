import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'property_image.dart';

/// Dashed "click here to upload" tile plus a thumbnail strip of what has been
/// chosen, matching the upload control in the prototype.
///
/// Shared by the create-listing form and the write-review sheet so both
/// screens behave and look identical.
class PhotoPickerField extends StatelessWidget {
  final List<String> photos;
  final bool busy;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final int max;
  final String emptyLabel;

  const PhotoPickerField({
    super.key,
    required this.photos,
    required this.busy,
    required this.onAdd,
    required this.onRemove,
    this.max = 6,
    this.emptyLabel = 'Click here to upload',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canAddMore = photos.length < max;

    if (photos.isEmpty) {
      return _UploadTile(busy: busy, label: emptyLabel, onTap: onAdd);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length + (canAddMore ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == photos.length) {
                return _AddSquare(busy: busy, onTap: onAdd);
              }
              final path = photos[index];
              return _Thumbnail(
                path: path,
                isCover: index == 0,
                onRemove: () => onRemove(path),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${photos.length} of $max selected',
          style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
        ),
      ],
    );
  }
}

class _UploadTile extends StatelessWidget {
  final bool busy;
  final String label;
  final VoidCallback onTap;

  const _UploadTile({
    required this.busy,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 132,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryFaint,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primarySoft, width: 1.4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (busy)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )
            else
              const Icon(
                Icons.cloud_upload_outlined,
                size: 34,
                color: AppColors.primary,
              ),
            const SizedBox(height: 10),
            Text(
              busy ? 'Opening your photos…' : label,
              style: textTheme.bodySmall?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSquare extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;

  const _AddSquare({required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 96,
        decoration: BoxDecoration(
          color: AppColors.primaryFaint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primarySoft, width: 1.4),
        ),
        child: busy
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              )
            : const Icon(Icons.add, color: AppColors.primary, size: 30),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String path;
  final bool isCover;
  final VoidCallback onRemove;

  const _Thumbnail({
    required this.path,
    required this.isCover,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PropertyImage(url: path, radius: BorderRadius.circular(12)),
          if (isCover)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Cover',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
