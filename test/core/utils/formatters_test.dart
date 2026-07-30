import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/utils/formatters.dart';

/// Unit tests for the display/date helpers used by the booking flow.
void main() {
  group('Formatters date helpers', () {
    test('shortDate renders as "dd MMM"', () {
      expect(Formatters.shortDate(DateTime(2026, 8, 8)), '08 Aug');
    });

    test('range joins both ends with a dash', () {
      expect(
        Formatters.range(DateTime(2026, 8, 8), DateTime(2026, 9, 12)),
        '08 Aug - 12 Sep',
      );
    });
  });

  group('Formatters money helpers', () {
    test('money always shows two decimal places', () {
      expect(Formatters.money(330), '\$330.00');
      expect(Formatters.money(12.5), '\$12.50');
    });

    test('price rounds to whole currency units', () {
      expect(Formatters.price(120), '\$120');
      expect(Formatters.price(120.6), '\$121');
    });
  });

  group('Formatters.periodMonths', () {
    test('a stay shorter than a month still bills one period', () {
      final start = DateTime(2026, 8, 1);
      expect(Formatters.periodMonths(start, start), 1);
      expect(Formatters.periodMonths(start, DateTime(2026, 8, 10)), 1);
    });

    test('exactly 30 days is a single period', () {
      expect(
        Formatters.periodMonths(DateTime(2026, 8, 1), DateTime(2026, 8, 31)),
        1,
      );
    });

    test('a partial second month rounds up', () {
      // 31 days -> ceil(31 / 30) == 2
      expect(
        Formatters.periodMonths(DateTime(2026, 8, 1), DateTime(2026, 9, 1)),
        2,
      );
      expect(
        Formatters.periodMonths(DateTime(2026, 8, 1), DateTime(2026, 10, 1)),
        3,
      );
    });
  });
}
