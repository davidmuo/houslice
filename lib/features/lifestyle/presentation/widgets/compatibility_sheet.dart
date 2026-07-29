import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/compatibility.dart';
import '../../domain/entities/lifestyle_profile.dart';
import '../../domain/services/compatibility_scorer.dart';

/// Explains a compatibility score line by line.
///
/// The score is only useful if a student can see what drives it, so every
/// dimension is listed with its own agreement bar and a sentence naming the
/// two answers being compared.
Future<void> showCompatibilitySheet(
  BuildContext context, {
  required LifestyleProfile viewer,
  required LifestyleProfile host,
  required String hostName,
  required bool viewerHasProfile,
}) {
  final breakdown = CompatibilityScorer.compare(viewer, host);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _CompatibilitySheet(
      breakdown: breakdown,
      hostName: hostName,
      hostBio: host.bio,
      viewerHasProfile: viewerHasProfile,
    ),
  );
}

class _CompatibilitySheet extends StatelessWidget {
  final CompatibilityBreakdown breakdown;
  final String hostName;
  final String hostBio;
  final bool viewerHasProfile;

  const _CompatibilitySheet({
    required this.breakdown,
    required this.hostName,
    required this.hostBio,
    required this.viewerHasProfile,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Row(
            children: [
              _ScoreRing(score: breakdown.score, blocked: breakdown.blocked),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      breakdown.headline,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How you and $hostName line up',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!viewerHasProfile)
            const _Callout(
              icon: Icons.info_outline,
              text:
                  'This is an estimate. Take the lifestyle questionnaire to '
                  'get a score based on your own answers.',
            ),

          if (breakdown.blocked)
            _Callout(
              icon: Icons.block,
              tone: AppColors.danger,
              text: breakdown.blockedReason!,
            ),

          if (hostBio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About $hostName',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(hostBio, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          Text(
            'Breakdown',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Ranked by how well you agree.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: 12),

          for (final factor in breakdown.factors) _FactorRow(factor: factor),
        ],
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  final CompatibilityFactor factor;

  const _FactorRow({required this.factor});

  static IconData _iconFor(CompatibilityDimension dimension) =>
      switch (dimension) {
        CompatibilityDimension.cleanliness => Icons.cleaning_services_outlined,
        CompatibilityDimension.social => Icons.celebration_outlined,
        CompatibilityDimension.sleep => Icons.bedtime_outlined,
        CompatibilityDimension.guests => Icons.group_outlined,
        CompatibilityDimension.smoking => Icons.smoke_free,
        CompatibilityDimension.budget => Icons.payments_outlined,
        CompatibilityDimension.study => Icons.menu_book_outlined,
        CompatibilityDimension.sharing => Icons.shopping_basket_outlined,
        CompatibilityDimension.pets => Icons.pets_outlined,
      };

  Color get _tone {
    if (factor.isStrength) return AppColors.success;
    if (factor.isFriction) return AppColors.danger;
    return AppColors.star;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(_iconFor(factor.dimension), size: 19, color: _tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        factor.dimension.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${factor.score}%',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _tone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: factor.score / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(_tone),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  factor.note,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final int score;
  final bool blocked;

  const _ScoreRing({required this.score, required this.blocked});

  @override
  Widget build(BuildContext context) {
    final tone = blocked
        ? AppColors.danger
        : score >= 70
        ? AppColors.success
        : score >= 45
        ? AppColors.star
        : AppColors.danger;

    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(tone),
            ),
          ),
          Text(
            '$score',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color tone;

  const _Callout({
    required this.icon,
    required this.text,
    this.tone = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tone),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tone == AppColors.primary ? AppColors.dark : tone,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
