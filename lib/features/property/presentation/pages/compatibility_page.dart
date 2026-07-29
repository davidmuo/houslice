import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../lifestyle/domain/services/compatibility_scorer.dart';
import '../../../lifestyle/presentation/cubit/lifestyle_cubit.dart';
import '../bloc/property_bloc.dart';
import '../widgets/property_card.dart';

/// The "Popular List / see all" screen from the prototype: every listing,
/// ranked by how well it matches the student's questionnaire answers.
class CompatibilityPage extends StatelessWidget {
  const CompatibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compatibility')),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state.status == PropertyStatus.loading ||
              state.status == PropertyStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.properties.isEmpty) {
            return const EmptyState(
              icon: Icons.home_outlined,
              title: 'No listings yet',
              subtitle: Text('Publish one from your profile to get started.'),
            );
          }

          final viewer = context.read<LifestyleCubit>().state.effective;
          final ranked = [...state.properties]
            ..sort((a, b) {
              final sa = a.supportsCompatibility
                  ? CompatibilityScorer.scoreOnly(viewer, a.hostLifestyle!)
                  : a.compatibility;
              final sb = b.supportsCompatibility
                  ? CompatibilityScorer.scoreOnly(viewer, b.hostLifestyle!)
                  : b.compatibility;
              return sb.compareTo(sa);
            });

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: ranked.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final property = ranked[index];
              return PropertyCard(
                property: property,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.details, arguments: property),
                onFavoriteToggle: () => context.read<PropertyBloc>().add(
                  PropertyFavoriteToggled(property.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
