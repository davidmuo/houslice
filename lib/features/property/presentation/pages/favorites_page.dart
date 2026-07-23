import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../bloc/property_bloc.dart';
import '../widgets/property_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite')),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          final favorites = state.favorites;
          if (favorites.isEmpty) {
            return const EmptyState(
              header: 'Opps!!',
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              subtitle: Text(
                  'Tap the heart on any listing to save it for later'),
            );
          }
          return ListView.separated(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: favorites.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final property = favorites[index];
              return PropertyCard(
                property: property,
                showCompatibility: false,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.details,
                  arguments: property,
                ),
                onFavoriteToggle: () => context
                    .read<PropertyBloc>()
                    .add(PropertyFavoriteToggled(property.id)),
              );
            },
          );
        },
      ),
    );
  }
}
