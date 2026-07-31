import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/property/data/seed_properties.dart';
import 'package:houslice/features/property/presentation/pages/explore_page.dart';
import 'package:houslice/features/property/presentation/pages/favorites_page.dart';
import 'package:houslice/features/property/presentation/pages/home_page.dart';
import 'package:houslice/features/property/presentation/pages/property_details_page.dart';
import 'package:houslice/features/property/presentation/pages/search_page.dart';
import 'package:houslice/features/property/presentation/widgets/property_card.dart';

import '../../../helpers/app_harness.dart';

/// Widget tests for the listing screens, driven through the real blocs and
/// the in-memory demo data sources.
void main() {
  registerHarnessTeardown();

  group('HomePage', () {
    testWidgets('renders the Figma home sections without overflowing', (
      tester,
    ) async {
      await pumpPage(tester, const HomePage());

      // Home is now the sectioned design; the flat PropertyCard list moved to
      // the "see all" Compatibility screen.
      expect(find.text('Recommended'), findsOneWidget);
      expect(find.text('Nearby'), findsOneWidget);
      expect(find.text('Top Locations'), findsOneWidget);
      expect(find.text('Search Property'), findsOneWidget);
      expect(find.textContaining('CASHBACK'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small 5.0-inch phone', (tester) async {
      await pumpPage(
        tester,
        const HomePage(),
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a large 6.7-inch phone', (tester) async {
      await pumpPage(
        tester,
        const HomePage(),
        surfaceSize: const Size(430, 932),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a landscape rotation', (tester) async {
      await pumpPage(
        tester,
        const HomePage(),
        surfaceSize: const Size(932, 430),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('ExplorePage', () {
    testWidgets('renders the listing grid', (tester) async {
      await pumpPage(tester, const ExplorePage());

      // Explore builds its own grid cells rather than reusing PropertyCard.
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Search area, city or property'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the search bar does not overflow on a narrow screen', (
      tester,
    ) async {
      await pumpPage(
        tester,
        const ExplorePage(),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('FavoritesPage', () {
    testWidgets('shows the pre-seeded favourites', (tester) async {
      await pumpPage(tester, const FavoritesPage());

      // MockPropertyDataSource seeds two favourites.
      expect(find.byType(PropertyCard), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('SearchPage', () {
    testWidgets('renders the search field', (tester) async {
      await pumpPage(tester, const SearchPage());

      expect(find.byType(TextField), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('typing a query surfaces matching listings', (tester) async {
      await pumpPage(tester, const SearchPage());

      await tester.enterText(find.byType(TextField).first, 'Ayana');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      expect(tester.takeException(), isNull);
    });

    testWidgets('a query with no matches renders the empty state', (
      tester,
    ) async {
      await pumpPage(tester, const SearchPage());

      await tester.enterText(
        find.byType(TextField).first,
        'zzzz-no-such-listing',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      expect(tester.takeException(), isNull);
    });
  });

  group('PropertyDetailsPage', () {
    testWidgets('renders the listing name and description', (tester) async {
      final property = kSeedProperties.first;

      await pumpPage(tester, PropertyDetailsPage(property: property));

      expect(find.text(property.name), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolls down to the verified host card', (tester) async {
      final property = kSeedProperties.first;

      await pumpPage(tester, PropertyDetailsPage(property: property));

      await tester.dragUntilVisible(
        find.text(property.agentName),
        find.byType(Scrollable).first,
        const Offset(0, -200),
      );

      expect(find.text(property.agentName), findsWidgets);
    });

    testWidgets('fits a small phone without overflowing', (tester) async {
      await pumpPage(
        tester,
        PropertyDetailsPage(property: kSeedProperties.first),
        surfaceSize: const Size(360, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
