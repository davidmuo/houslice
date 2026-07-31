import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/booking.dart';

/// Booking row on the My Booking screen with a status chip.
class BookingTile extends StatelessWidget {
  final Booking booking;

  /// Opens the listing the booking is for. Optional so the tile can still be
  /// rendered somewhere non-navigable.
  final VoidCallback? onTap;

  const BookingTile({super.key, required this.booking, this.onTap});

  (Color, Color) get _chipColors => switch (booking.status) {
    BookingStatus.waitingPayment => (AppColors.dangerSoft, AppColors.danger),
    BookingStatus.checkin ||
    BookingStatus.completed => (AppColors.successSoft, AppColors.success),
    BookingStatus.cancelled => (AppColors.surface, AppColors.grey),
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (chipBg, chipFg) = _chipColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PropertyImage(
              url: booking.propertyImage,
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
                    booking.propertyName,
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
                          booking.propertyAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // The date range yields space to the status chip and
                  // ellipsises instead of overflowing on narrow tiles.
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Formatters.range(booking.startDate, booking.endDate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: StatusChip(
                          label: booking.status.label,
                          background: chipBg,
                          foreground: chipFg,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
