import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/property.dart';
import 'host_badge.dart';

/// Horizontal listing tile used on Home (with compatibility score) and
/// reused across Explore and Favorites.
class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool showCompatibility;

  /// Live score for the signed-in student, computed from their questionnaire
  /// answers. Falls back to the listing's advertised [Property.compatibility]
  /// when the student has not taken the quiz yet.
  final int? compatibilityScore;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onFavoriteToggle,
    this.showCompatibility = true,
    this.compatibilityScore,
  });

  /// Compatibility is meaningless for a whole empty property — there is no
  /// housemate to be compatible with.
  bool get _showsScore => showCompatibility && property.isHousemateListing;

  int get _score => compatibilityScore ?? property.compatibility;

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
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Who listed it, and whether it is a room or a whole place.
                  Row(
                    children: [
                      HostBadge(hostType: property.hostType),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          property.listingKind.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // The price group takes whatever the chip leaves and
                      // ellipsises rather than overflowing on narrow cards.
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                Formatters.price(property.pricePerMonth),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '/month',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showsScore)
                        StatusChip(
                          label: '$_score% match',
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
                property.isFavorite ? Icons.favorite : Icons.favorite_border,
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
