import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubits/toggle_cubit.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';
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
                  onPressed: () => context
                      .read<PropertyBloc>()
                      .add(PropertyFavoriteToggled(property.id)),
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
                              for (var i = 0;
                                  i < property.images.length;
                                  i++)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == current
                                        ? AppColors.primary
                                        : Colors.white
                                            .withValues(alpha: .8),
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
                        style: textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
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
                            style: textTheme.bodyMedium
                                ?.copyWith(color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 18, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.address,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.star, size: 22),
                    const SizedBox(width: 4),
                    Text(
                      property.rating.toStringAsFixed(1),
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 16),
                    StatusChip(
                      label: '${property.compatibility}% compatible',
                      background: AppColors.compatibilitySoft,
                      foreground: AppColors.dark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Facility(
                        icon: Icons.bed_outlined,
                        label: '${property.bedrooms} Bedroom'),
                    const SizedBox(width: 12),
                    _Facility(
                        icon: Icons.bathtub_outlined,
                        label: '${property.bathrooms} Bathroom'),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'About',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  property.description,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.grey, height: 1.6),
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
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Verified host',
                              style: textTheme.bodySmall
                                  ?.copyWith(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: Text(
                                  'Calling ${property.agentName} — ${property.agentPhone}'),
                            ));
                        },
                        icon: const Icon(Icons.call_outlined,
                            color: AppColors.primary),
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
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.booking,
                    arguments: property,
                  ),
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
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
