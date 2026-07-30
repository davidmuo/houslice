import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/pages/my_bookings_page.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../property/presentation/bloc/property_bloc.dart';
import '../../../property/presentation/pages/explore_page.dart';
import '../../../property/presentation/pages/favorites_page.dart';
import '../../../property/presentation/pages/home_page.dart';
import '../cubit/nav_cubit.dart';

/// Main app scaffold: bottom navigation over the five tab pages.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

/// Stateful only to kick off data loading once the user reaches the shell
/// (after sign-in, so per-user favorites/bookings resolve correctly).
class _MainShellState extends State<MainShell> {
  static const _pages = [
    HomePage(),
    ExplorePage(),
    FavoritesPage(),
    MyBookingsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(const PropertiesRequested());
    context.read<BookingBloc>().add(const BookingsRequested());
    context.read<NotificationsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavCubit(),
      child: BlocBuilder<NavCubit, int>(
        builder: (context, index) => Scaffold(
          body: IndexedStack(index: index, children: _pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: context.read<NavCubit>().select,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore_rounded),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Favorite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'My Booking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
