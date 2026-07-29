import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/kigali_districts.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../lifestyle/domain/services/compatibility_scorer.dart';
import '../../../lifestyle/presentation/cubit/lifestyle_cubit.dart';
import '../../../settings/presentation/cubit/preferences_cubit.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';
import '../widgets/host_badge.dart';

/// Home tab, following the "Home" screen of the prototype: location header,
/// search entry, promo banner, then Recommended / Nearby / Top Locations /
/// Popular for you sections.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PropertyBloc, PropertyState>(
          builder: (context, state) {
            switch (state.status) {
              case PropertyStatus.initial:
              case PropertyStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              case PropertyStatus.failure:
                return EmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'Could not load listings',
                  subtitle: Text(state.message ?? 'Please try again.'),
                );
              case PropertyStatus.loaded:
                return _HomeBody(properties: state.properties);
            }
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final List<Property> properties;

  const _HomeBody({required this.properties});

  /// Listings ordered by how well they match the student's questionnaire.
  List<Property> _byCompatibility(BuildContext context) {
    final viewer = context.read<LifestyleCubit>().state.effective;
    final scored = [...properties]
      ..sort((a, b) {
        final sa = a.supportsCompatibility
            ? CompatibilityScorer.scoreOnly(viewer, a.hostLifestyle!)
            : a.compatibility;
        final sb = b.supportsCompatibility
            ? CompatibilityScorer.scoreOnly(viewer, b.hostLifestyle!)
            : b.compatibility;
        return sb.compareTo(sa);
      });
    return scored;
  }

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return const EmptyState(
        icon: Icons.home_outlined,
        title: 'No listings yet',
        subtitle: Text('Be the first — publish one from your profile.'),
      );
    }

    final ranked = _byCompatibility(context);
    final district = context
        .watch<PreferencesCubit>()
        .state
        .preferences
        .preferredCity;
    // Addresses name the neighbourhood, not the district, so a substring match
    // on "Gasabo" would never hit "…, Kimihurura, Kigali".
    final nearby = properties
        .where((p) => KigaliDistricts.isIn(p.address, district))
        .toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          context.read<PropertyBloc>().add(const PropertiesRequested()),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _LocationHeader(),
          const SizedBox(height: 14),
          const _SearchEntry(),
          const SizedBox(height: 18),
          const _PromoBanner(),
          const SizedBox(height: 22),

          _SectionHeader(
            title: 'Recommended',
            onSeeAll: () =>
                Navigator.of(context).pushNamed(AppRoutes.compatibility),
          ),
          const SizedBox(height: 12),
          _HorizontalStrip(properties: ranked.take(6).toList()),
          const SizedBox(height: 22),

          _SectionHeader(
            title: 'Nearby',
            onSeeAll: () =>
                Navigator.of(context).pushNamed(AppRoutes.compatibility),
          ),
          const SizedBox(height: 12),
          if (nearby.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Nothing listed in $district yet — change your district in '
                'Settings.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
              ),
            )
          else
            _HorizontalStrip(properties: nearby),
          const SizedBox(height: 22),

          const _SectionHeader(title: 'Top Locations'),
          const SizedBox(height: 12),
          const _TopLocations(),
          const SizedBox(height: 22),

          _SectionHeader(
            title: 'Popular for you',
            onSeeAll: () =>
                Navigator.of(context).pushNamed(AppRoutes.compatibility),
          ),
          const SizedBox(height: 4),
          for (final property in ranked.take(4))
            _PopularRow(property: property),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// "Location ▾ / Kigali" with the notification and message actions.
class _LocationHeader extends StatelessWidget {
  const _LocationHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final district = context
        .watch<PreferencesCubit>()
        .state
        .preferences
        .preferredCity;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.locationPicker),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Location',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$district, Kigali',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _CircleAction(
            icon: Icons.notifications_none_rounded,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.notifications),
          ),
          const SizedBox(width: 8),
          _CircleAction(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('In-app messaging is coming next release'),
                  ),
                );
            },
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.dark),
      ),
    );
  }
}

/// Tappable search bar that opens the full search screen.
class _SearchEntry extends StatelessWidget {
  const _SearchEntry();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search Property',
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.grey),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryFaint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The orange cashback card from the design.
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GET YOUR 50%\nCASHBACK',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'On your first student sublet',
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 42,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      ),
    );
  }
}

/// Horizontally scrolling cards used by Recommended and Nearby.
class _HorizontalStrip extends StatelessWidget {
  final List<Property> properties;

  const _HorizontalStrip({required this.properties});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: properties.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) =>
            _StripCard(property: properties[index]),
      ),
    );
  }
}

class _StripCard extends StatelessWidget {
  final Property property;

  const _StripCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 190,
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).pushNamed(AppRoutes.details, arguments: property),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                PropertyImage(
                  url: property.coverImage,
                  width: 190,
                  height: 124,
                  radius: BorderRadius.circular(16),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${Formatters.price(property.pricePerMonth)}/month',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: HostBadge(hostType: property.hostType, compact: true),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              property.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    property.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// District chips, matching the "Top Locations" row.
class _TopLocations extends StatelessWidget {
  const _TopLocations();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PreferencesCubit>();
    final selected = context
        .watch<PreferencesCubit>()
        .state
        .preferences
        .preferredCity;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          for (final district in KigaliDistricts.districts)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(district),
                selected: district == selected,
                onSelected: (_) => cubit.setPreferredCity(district),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact row used by "Popular for you".
class _PopularRow extends StatelessWidget {
  final Property property;

  const _PopularRow({required this.property});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.details, arguments: property),
      leading: PropertyImage(
        url: property.coverImage,
        width: 64,
        height: 64,
        radius: BorderRadius.circular(12),
      ),
      title: Text(
        property.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${property.address}\n${Formatters.price(property.pricePerMonth)}/month',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
      ),
      isThreeLine: true,
      trailing: IconButton(
        onPressed: () => context.read<PropertyBloc>().add(
          PropertyFavoriteToggled(property.id),
        ),
        icon: Icon(
          property.isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: property.isFavorite ? AppColors.danger : AppColors.grey,
        ),
      ),
    );
  }
}
