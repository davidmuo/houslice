import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';

/// "My Listings" — everything the signed-in student has published, with the
/// edit and delete actions the Firestore rules already grant an owner.
///
/// Ownership is decided by `ownerUid`, the same field the security rules
/// check, so what the screen offers and what the backend permits cannot drift
/// apart.
class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  /// Confirms before destroying something the student cannot get back.
  Future<void> _confirmDelete(BuildContext context, Property listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text(
          '"${listing.name}" will be removed for everyone. This cannot be '
          'undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // The dialog's own context is gone by now, so guard the page's before
    // touching the bloc it belongs to.
    if (confirmed != true || !context.mounted) return;
    context.read<PropertyBloc>().add(PropertyDeleted(listing.id));
  }

  @override
  Widget build(BuildContext context) {
    // Ownership comes from the auth session, never from a route argument.
    final uid = context.select<AuthBloc, String>(
      (bloc) => bloc.state.user?.uid ?? '',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoutes.createListing),
        icon: const Icon(Icons.add),
        label: const Text('New listing'),
      ),
      body: BlocConsumer<PropertyBloc, PropertyState>(
        listenWhen: (previous, current) =>
            previous.message != current.message && current.message != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        },
        builder: (context, state) {
          final listings = state.mine(uid);

          if (listings.isEmpty) {
            return const EmptyState(
              header: 'Opps!!',
              icon: Icons.home_work_outlined,
              title: 'You have not listed anything yet',
              subtitle: Text(
                'Publish a room or a whole place and it will show up here',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<PropertyBloc>().add(const PropertiesRequested()),
            child: ListView.separated(
              // Extra bottom padding so the last row clears the FAB.
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              itemCount: listings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _OwnedListingTile(
                listing: listings[index],
                onEdit: () => Navigator.of(context).pushNamed(
                  AppRoutes.createListing,
                  arguments: listings[index],
                ),
                onDelete: () => _confirmDelete(context, listings[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A listing row with its owner-only actions.
class _OwnedListingTile extends StatelessWidget {
  final Property listing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OwnedListingTile({
    required this.listing,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PropertyImage(
                  url: listing.coverImage,
                  width: 84,
                  height: 84,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${Formatters.price(listing.pricePerMonth)} / month',
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Wrap rather than Row: on a narrow phone the two buttons drop onto
          // a second line instead of overflowing.
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
