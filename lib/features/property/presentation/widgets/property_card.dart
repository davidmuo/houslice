import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/property.dart';

/// Horizontal listing tile used on Home (with compatibility score) and
/// reused across Explore and Favorites.
class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool showCompatibility;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onFavoriteToggle,
    this.showCompatibility = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PropertyImage(
              url: property.coverImage,
              width: 96,
              height: 96,
              radius: BorderRadius.circular(14),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        Formatters.price(property.pricePerMonth),
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '/month',
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.grey),
                      ),
                      const Spacer(),
                      if (showCompatibility)
                        StatusChip(
                          label: '${property.compatibility}%',
                          background: AppColors.compatibilitySoft,
                          foreground: AppColors.dark,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onFavoriteToggle,
              icon: Icon(
                property.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: property.isFavorite
                    ? AppColors.danger
                    : AppColors.danger.withValues(alpha: .7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
