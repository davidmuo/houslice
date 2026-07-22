import 'dart:math' as math;

import 'package:intl/intl.dart';

abstract final class Formatters {
  static String shortDate(DateTime d) => DateFormat('dd MMM').format(d);

  /// e.g. "08 Aug - 12 Sep"
  static String range(DateTime start, DateTime end) =>
      '${shortDate(start)} - ${shortDate(end)}';

  /// e.g. "$330.00"
  static String money(num v) => '\$${v.toStringAsFixed(2)}';

  /// e.g. "$120"
  static String price(num v) => '\$${v.toStringAsFixed(0)}';

  /// Number of monthly billing periods a stay covers (minimum one).
  static int periodMonths(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    return math.max(1, (days / 30).ceil());
  }
}
