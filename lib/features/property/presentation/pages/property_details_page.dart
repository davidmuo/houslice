import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubits/toggle_cubit.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../lifestyle/domain/entities/lifestyle_profile.dart';
import '../../../lifestyle/domain/services/compatibility_scorer.dart';
import '../../../lifestyle/presentation/cubit/lifestyle_cubit.dart';
import '../../../lifestyle/presentation/widgets/compatibility_sheet.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';
import '../widgets/host_badge.dart';
import '../widgets/share_sheet.dart';

class PropertyDetailsPage extends StatefulWidget {
  final Property property;

  const PropertyDetailsPage({super.key, required this.property});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

/// Stateful only for the gallery PageController; the selected image index
/// lives in an [IndexCubit].
class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  final _galleryController = PageController();

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocProvider(
      create: (_) => IndexCubit(),
      child: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          // Prefer the live copy from the bloc so the heart stays in sync.
          final property = state.byId(widget.property.id) ?? widget.property;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Details'),
              actions: [
                IconButton(
                  onPressed: () => showShareSheet(context, property),
                  icon: const Icon(Icons.share_outlined),
                ),
                IconButton(
                  onPressed: () => context.read<PropertyBloc>().add(
                    PropertyFavoriteToggled(property.id),
                  ),
                  icon: Icon(
                    property.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: property.isFavorite
                        ? AppColors.danger
                        : AppColors.dark,
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                SizedBox(
                  height: 260,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _galleryController,
                        itemCount: property.images.length,
                        onPageChanged: context.read<IndexCubit>().set,
                        itemBuilder: (context, index) => PropertyImage(
                          url: property.images[index],
                          radius: BorderRadius.circular(20),
                          width: double.infinity,
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 0,
                        right: 0,
                        child: BlocBuilder<IndexCubit, int>(
                          builder: (context, current) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < property.images.length; i++)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == current
                                        ? AppColors.primary
                                        : Colors.white.withValues(alpha: .8),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: property.images.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) => InkWell(
                      onTap: () => _galleryController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: PropertyImage(
                        url: property.images[index],
                        width: 96,
                        height: 72,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        property.name,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: Formatters.price(property.pricePerMonth),
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                        children: [
                          TextSpan(
                            text: '/month',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.address,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.star,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      property.rating.toStringAsFixed(1),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    HostBadge(hostType: property.hostType),
                  ],
                ),
                const SizedBox(height: 16),
                // Compatibility only applies to shared homes; an entire place
                // has no housemate to be compatible with.
                if (property.isHousemateListing)
                  BlocBuilder<LifestyleCubit, LifestyleState>(
                    builder: (context, lifestyle) {
                      final host =
                          property.hostLifestyle ?? LifestyleProfile.empty;
                      final score = property.hostLifestyle == null
                          ? property.compatibility
                          : CompatibilityScorer.scoreOnly(
                              lifestyle.effective,
                              host,
                            );

                      return _CompatibilityBanner(
                        score: score,
                        explainable: property.hostLifestyle != null,
                        onExplain: () => showCompatibilitySheet(
                          context,
                          viewer: lifestyle.effective,
                          host: host,
                          hostName: property.agentName,
                          viewerHasProfile: lifestyle.hasProfile,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                Text(
                  'Property Details',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                // Two rows of three, matching the details grid in the design.
                Row(
                  children: [
                    Expanded(
                      child: _Facility(
                        icon: Icons.bed_outlined,
                        label: '${property.bedrooms} Bedroom',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Facility(
                        icon: Icons.bathtub_outlined,
                        label: '${property.bathrooms} Bathroom',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Facility(
                        icon: Icons.people_outline,
                        label: property.isHousemateListing
                            ? 'Shared home'
                            : 'Entire place',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Facility(
                        icon: Icons.event_available_outlined,
                        label: 'Available now',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'About',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                _ExpandableDescription(text: property.description),
                const SizedBox(height: 20),

                Text(
                  'Location & Public Facilities',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _FacilityChip(
                      icon: Icons.local_hospital_outlined,
                      label: 'Hospital',
                    ),
                    _FacilityChip(
                      icon: Icons.local_gas_station_outlined,
                      label: 'Gas station',
                    ),
                    _FacilityChip(
                      icon: Icons.storefront_outlined,
                      label: 'Mall',
                    ),
                    _FacilityChip(icon: Icons.school_outlined, label: 'Campus'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reviews',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: AppColors.star,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          property.rating == 0
                              ? 'New listing'
                              : property.rating.toStringAsFixed(1),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  property.rating == 0
                      ? 'No reviews yet. Be the first to stay here and leave one.'
                      : 'Reviews are written by verified students after a '
                            'completed stay.',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryFaint,
                        child: Text(
                          property.agentName.isEmpty
                              ? '?'
                              : property.agentName[0],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.agentName,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Verified host',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Calling ${property.agentName} — ${property.agentPhone}',
                                ),
                              ),
                            );
                        },
                        icon: const Icon(
                          Icons.call_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.booking, arguments: property),
                  child: const Text('Book Now'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Facility extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Facility({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Headline compatibility figure with the entry point to the full breakdown.
class _CompatibilityBanner extends StatelessWidget {
  final int score;

  /// False when the host has not taken the questionnaire, so there is nothing
  /// to explain and the button is hidden rather than opening an empty sheet.
  final bool explainable;
  final VoidCallback onExplain;

  const _CompatibilityBanner({
    required this.score,
    required this.explainable,
    required this.onExplain,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tone = score >= 70
        ? AppColors.success
        : score >= 45
        ? AppColors.star
        : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.compatibilitySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$score',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: tone,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lifestyle match',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  explainable
                      ? 'Based on your questionnaire answers'
                      : 'This host has not taken the questionnaire yet',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.dark),
                ),
              ],
            ),
          ),
          if (explainable)
            TextButton(onPressed: onExplain, child: const Text('Why?')),
        ],
      ),
    );
  }
}

/// Description that collapses to four lines behind a "Read more" toggle,
/// matching the details screen in the prototype.
class _ExpandableDescription extends StatefulWidget {
  final String text;

  const _ExpandableDescription({required this.text});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

/// Stateful only to hold the expanded flag for this one block.
class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.bodyMedium?.copyWith(
      color: AppColors.grey,
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _expanded ? null : 4,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: style,
        ),
        if (widget.text.length > 160)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _expanded ? 'Read less' : 'Read more',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Small labelled pill used by "Location & Public Facilities".
class _FacilityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FacilityChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
