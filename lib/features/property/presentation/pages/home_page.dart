import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../bloc/property_bloc.dart';
import '../widgets/property_card.dart';

/// Home tab: listings ranked by lifestyle compatibility, as in the Figma
/// "Compatibility" screen.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compatibility'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: BlocBuilder<PropertyBloc, PropertyState>(
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
              final properties = [...state.properties]
                ..sort((a, b) => b.compatibility.compareTo(a.compatibility));
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => context
                    .read<PropertyBloc>()
                    .add(const PropertiesRequested()),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  itemCount: properties.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    return PropertyCard(
                      property: property,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.details,
                        arguments: property,
                      ),
                      onFavoriteToggle: () => context
                          .read<PropertyBloc>()
                          .add(PropertyFavoriteToggled(property.id)),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
