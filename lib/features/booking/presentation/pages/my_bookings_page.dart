import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubits/toggle_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../widgets/booking_tile.dart';
import '../widgets/review_sheet.dart';

/// "My Booking" tab with Upcoming / Completed / Cancelled segments.
class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  static const _tabs = ['Upcoming', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IndexCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Booking')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: BlocBuilder<IndexCubit, int>(
                builder: (context, selected) => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < _tabs.length; i++)
                        Expanded(
                          child: InkWell(
                            onTap: () => context.read<IndexCubit>().set(i),
                            borderRadius: BorderRadius.circular(11),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: i == selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              alignment: Alignment.center,
                              // scaleDown keeps all three labels readable and
                              // un-truncated on narrow screens.
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _tabs[i],
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: i == selected
                                            ? Colors.white
                                            : AppColors.grey,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  if (state.status == BookingViewStatus.loading ||
                      state.status == BookingViewStatus.initial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  return BlocBuilder<IndexCubit, int>(
                    builder: (context, selected) {
                      final bookings = switch (selected) {
                        0 => state.upcoming,
                        1 => state.completed,
                        _ => state.cancelled,
                      };
                      if (bookings.isEmpty) {
                        return _EmptyBookings(tab: selected);
                      }
                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async => context.read<BookingBloc>().add(
                          const BookingsRequested(),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          itemCount: bookings.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BookingTile(booking: booking),
                                if (booking.status ==
                                    BookingStatus.completed) ...[
                                  const Divider(),
                                  _ActionRow(
                                    icon: Icons.rate_review_outlined,
                                    label: 'Write review',
                                    onTap: () =>
                                        showReviewSheet(context, booking),
                                  ),
                                  const Divider(),
                                  _ActionRow(
                                    icon: Icons.call_outlined,
                                    label: 'Call Agent',
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Connecting you to the agent...',
                                            ),
                                          ),
                                        );
                                    },
                                  ),
                                ],
                                if (booking.status ==
                                    BookingStatus.waitingPayment) ...[
                                  const Divider(),
                                  _ActionRow(
                                    icon: Icons.close,
                                    label: 'Cancel booking',
                                    onTap: () => context
                                        .read<BookingBloc>()
                                        .add(BookingCancelled(booking.id)),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  final int tab;

  const _EmptyBookings({required this.tab});

  @override
  Widget build(BuildContext context) {
    final label = switch (tab) {
      0 => 'upcoming',
      1 => 'completed',
      _ => 'cancelled',
    };
    return EmptyState(
      header: 'Opps!!',
      icon: Icons.luggage_outlined,
      title: 'You have no $label booking',
      subtitle: Column(
        children: [
          const Text('are you looking for a'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (tab != 1)
                TextButton(
                  onPressed: () => context.read<IndexCubit>().set(1),
                  child: const Text(
                    'completed',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (tab == 1)
                TextButton(
                  onPressed: () => context.read<IndexCubit>().set(0),
                  child: const Text(
                    'upcoming',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const Text('or'),
              if (tab != 2)
                TextButton(
                  onPressed: () => context.read<IndexCubit>().set(2),
                  child: const Text(
                    'cancelled',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (tab == 2)
                TextButton(
                  onPressed: () => context.read<IndexCubit>().set(0),
                  child: const Text(
                    'upcoming',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const Text('booking ?'),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
