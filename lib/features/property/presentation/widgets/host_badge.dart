import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/property.dart';

/// Small pill marking whether a listing came from a fellow student or a
/// letting agent — the single most requested signal in user interviews, where
/// students said they could not tell peers from agents on Facebook.
class HostBadge extends StatelessWidget {
  final HostType hostType;

  /// Compact form drops the text and keeps the icon, for dense card corners.
  final bool compact;

  const HostBadge({super.key, required this.hostType, this.compact = false});

  static IconData iconFor(HostType type) => switch (type) {
    HostType.student => Icons.school_outlined,
    HostType.realtor => Icons.business_center_outlined,
  };

  Color get _background => switch (hostType) {
    HostType.student => AppColors.primaryFaint,
    HostType.realtor => AppColors.successSoft,
  };

  Color get _foreground => switch (hostType) {
    HostType.student => AppColors.primaryDark,
    HostType.realtor => AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    final icon = Icon(iconFor(hostType), size: 14, color: _foreground);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: 5),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: compact
          ? icon
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    hostType.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
