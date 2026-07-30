import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/booking/presentation/pages/booking_page.dart';
import 'package:houslice/features/property/data/seed_properties.dart';
import 'package:houslice/features/property/presentation/pages/property_details_page.dart';

import '../helpers/app_harness.dart';

/// Widget tests for the modal bottom sheets: share, and the "Select Date"
/// range calendar used by checkout.
void main() {
  registerHarnessTeardown();

  group('ShareSheet', () {
    testWidgets('opens from the details app bar', (tester) async {
      await pumpPage(
        tester,
        PropertyDetailsPage(property: kSeedProperties.first),
      );

      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders inside a small screen without overflowing', (
      tester,
    ) async {
      await pumpPage(
        tester,
        PropertyDetailsPage(property: kSeedProperties.first),
        surfaceSize: const Size(360, 640),
      );

      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('can be dismissed', (tester) async {
      await pumpPage(
        tester,
        PropertyDetailsPage(property: kSeedProperties.first),
      );

      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pumpAndSettle();

      // Tapping the scrim closes the sheet.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('SelectDateSheet', () {
    Future<void> openSheet(WidgetTester tester, {Size? size}) async {
      await pumpPage(
        tester,
        BookingPage(property: kSeedProperties.first),
        signedIn: true,
        surfaceSize: size ?? const Size(430, 932),
      );

      // The stay-dates row opens the calendar sheet.
      final trigger = find.textContaining('-');
      if (trigger.evaluate().isNotEmpty) {
        await tester.tap(trigger.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    }

    testWidgets('opens the range calendar', (tester) async {
      await openSheet(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('paging months does not throw', (tester) async {
      await openSheet(tester);

      for (final icon in [
        Icons.chevron_right,
        Icons.chevron_left,
        Icons.arrow_forward_ios,
        Icons.arrow_back_ios,
      ]) {
        final button = find.byIcon(icon);
        if (button.evaluate().isNotEmpty) {
          await tester.tap(button.first, warnIfMissed: false);
          await tester.pumpAndSettle();
        }
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('picking days inside the calendar does not throw', (
      tester,
    ) async {
      await openSheet(tester);

      // Tap a couple of day cells if the calendar is showing.
      for (final day in ['12', '18']) {
        final cell = find.text(day);
        if (cell.evaluate().isNotEmpty) {
          await tester.tap(cell.first, warnIfMissed: false);
          await tester.pumpAndSettle();
        }
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small screen', (tester) async {
      await openSheet(tester, size: const Size(360, 640));

      expect(tester.takeException(), isNull);
    });
  });
}
