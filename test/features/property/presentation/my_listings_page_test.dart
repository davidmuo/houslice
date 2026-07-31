import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/property/data/datasources/property_data_source.dart';
import 'package:houslice/features/property/data/models/property_model.dart';
import 'package:houslice/features/property/presentation/pages/my_listings_page.dart';
import 'package:houslice/injection_container.dart' as di;

import '../../../fixtures/property_fixtures.dart';
import '../../../helpers/app_harness.dart';

/// Widget tests for the owner-only listing management screen.
///
/// The harness boots the real dependency graph in demo mode, so these exercise
/// the bloc, use cases, and the in-memory data source together — a delete here
/// really does travel through `DeleteListing` to `MockPropertyDataSource`.
void main() {
  registerHarnessTeardown();

  testWidgets('shows the empty state when the student has published nothing', (
    tester,
  ) async {
    // The seeded catalogue has an empty ownerUid, so none of it belongs to the
    // signed-in student.
    await pumpPage(tester, const MyListingsPage(), signedIn: true);

    expect(find.text('You have not listed anything yet'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
  });

  testWidgets('offers a route to publish a first listing', (tester) async {
    await pumpPage(tester, const MyListingsPage(), signedIn: true);

    expect(find.text('New listing'), findsOneWidget);
  });

  testWidgets('never offers edit or delete on the seeded catalogue', (
    tester,
  ) async {
    // Guards the ownership check: seeded listings carry an empty ownerUid and
    // the Firestore rules would reject an edit, so the buttons must not appear.
    await pumpPage(tester, const MyListingsPage(), signedIn: true);

    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('lays out without overflow at landscape and small sizes', (
    tester,
  ) async {
    for (final size in const [Size(932, 430), Size(320, 568)]) {
      await pumpPage(
        tester,
        const MyListingsPage(),
        signedIn: true,
        surfaceSize: size,
      );
      expect(tester.takeException(), isNull, reason: 'overflowed at $size');
    }
  });

  group('with a listing the student published', () {
    /// Publishes a listing through the real data source so it comes back
    /// stamped with the demo owner uid, exactly as Firestore would stamp it.
    Future<void> publishOne() async {
      await di.sl<PropertyDataSource>().createListing(
        PropertyModel.fromEntity(
          buildProperty(id: '', name: 'My Spare Room', pricePerMonth: 150),
        ),
      );
    }

    /// Explicit pumps rather than `pumpAndSettle`: listing rows contain an
    /// `Image.network` whose future never resolves under the test HTTP client,
    /// so settling would never complete.
    Future<void> advance(WidgetTester tester) async {
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('lists it with edit and delete actions', (tester) async {
      await pumpPage(
        tester,
        const MyListingsPage(),
        signedIn: true,
        arrange: publishOne,
      );

      expect(find.text('My Spare Room'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('deleting asks for confirmation first', (tester) async {
      await pumpPage(
        tester,
        const MyListingsPage(),
        signedIn: true,
        arrange: publishOne,
      );

      await tester.tap(find.text('Delete'));
      await advance(tester);

      expect(find.text('Delete listing?'), findsOneWidget);

      // Backing out must leave the listing alone.
      await tester.tap(find.text('Cancel'));
      await advance(tester);

      expect(find.text('Delete listing?'), findsNothing);
      expect(find.text('My Spare Room'), findsOneWidget);
    });

    testWidgets('confirming the dialog removes the row', (tester) async {
      await pumpPage(
        tester,
        const MyListingsPage(),
        signedIn: true,
        arrange: publishOne,
      );

      await tester.tap(find.text('Delete'));
      await advance(tester);
      // The dialog's own Delete button, not the row's.
      await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
      await advance(tester);

      expect(find.text('My Spare Room'), findsNothing);
      expect(find.text('You have not listed anything yet'), findsOneWidget);
    });

    testWidgets('edit opens the form prefilled with the listing', (
      tester,
    ) async {
      await pumpPage(
        tester,
        const MyListingsPage(),
        signedIn: true,
        arrange: publishOne,
      );

      await tester.tap(find.text('Edit'));
      await advance(tester);

      // Edit mode, not publish mode.
      expect(find.text('Edit listing'), findsOneWidget);
      // The form opens on the listing's current values.
      expect(find.text('My Spare Room'), findsWidgets);
      expect(find.text('150'), findsWidgets);

      // The submit button sits at the bottom of a long form, so it is only
      // built once scrolled into view.
      await tester.scrollUntilVisible(
        find.text('Save changes'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Save changes'), findsOneWidget);
    });
  });
}
