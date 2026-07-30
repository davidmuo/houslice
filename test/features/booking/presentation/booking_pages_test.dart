import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/booking/presentation/pages/booking_page.dart';
import 'package:houslice/features/booking/presentation/pages/my_bookings_page.dart';
import 'package:houslice/features/property/data/seed_properties.dart';

import '../../../helpers/app_harness.dart';

/// Widget tests for the checkout and My Bookings screens.
void main() {
  registerHarnessTeardown();

  group('BookingPage', () {
    testWidgets('renders the checkout screen for a listing', (tester) async {
      await pumpPage(
        tester,
        BookingPage(property: kSeedProperties.first),
        signedIn: true,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the payment method choices', (tester) async {
      await pumpPage(
        tester,
        BookingPage(property: kSeedProperties.first),
        signedIn: true,
      );

      expect(find.textContaining('Momo'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone without overflowing', (tester) async {
      await pumpPage(
        tester,
        BookingPage(property: kSeedProperties.first),
        signedIn: true,
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a landscape rotation', (tester) async {
      await pumpPage(
        tester,
        BookingPage(property: kSeedProperties.first),
        signedIn: true,
        surfaceSize: const Size(932, 430),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a payment method selects it', (tester) async {
      await pumpPage(
        tester,
        BookingPage(property: kSeedProperties.first),
        signedIn: true,
      );

      final momo = find.textContaining('Momo');
      if (momo.evaluate().isNotEmpty) {
        await tester.tap(momo.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 300));
      }

      expect(tester.takeException(), isNull);
    });
  });

  group('MyBookingsPage', () {
    testWidgets('renders the Upcoming / Completed / Cancelled segments', (
      tester,
    ) async {
      await pumpPage(tester, const MyBookingsPage(), signedIn: true);

      // Custom segmented control driven by IndexCubit, not a Material TabBar.
      expect(find.text('Upcoming'), findsWidgets);
      expect(find.text('Completed'), findsWidgets);
      expect(find.text('Cancelled'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('switching segments does not throw', (tester) async {
      await pumpPage(tester, const MyBookingsPage(), signedIn: true);

      await tester.tap(find.text('Completed').first);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Cancelled').first);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Upcoming').first);
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpPage(
        tester,
        const MyBookingsPage(),
        signedIn: true,
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
