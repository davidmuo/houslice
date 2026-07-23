import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/property_image.dart';
import '../bloc/property_bloc.dart';

/// Explore tab: search entry point plus a grid of all listings.
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
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
                    Text(
                      'Search area, city or property',
                      style: textTheme.bodyLarge
                          ?.copyWith(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<PropertyBloc, PropertyState>(
              builder: (context, state) {
                if (state.status == PropertyStatus.loading ||
                    state.status == PropertyStatus.initial) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: .78,
                  ),
                  itemCount: state.properties.length,
                  itemBuilder: (context, index) {
                    final property = state.properties[index];
                    return InkWell(
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.details,
                        arguments: property,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: PropertyImage(
                                    url: property.coverImage,
                                    radius: BorderRadius.circular(16),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: () => context
                                        .read<PropertyBloc>()
                                        .add(PropertyFavoriteToggled(
                                            property.id)),
                                    customBorder: const CircleBorder(),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        property.isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 18,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            property.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              text: Formatters.price(
                                  property.pricePerMonth),
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                              children: [
                                TextSpan(
                                  text: '/month',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
