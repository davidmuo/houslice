import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/features/booking/presentation/cubit/booking_form_cubit.dart';

/// Unit tests for the checkout form: range selection, month paging and
/// payment method choice.
void main() {
  late BookingFormCubit cubit;

  setUp(() => cubit = BookingFormCubit());
  tearDown(() => cubit.close());

  group('initial state', () {
    test('opens with a valid one-month range starting a week out', () {
      expect(cubit.state.start, isNotNull);
      expect(cubit.state.end, isNotNull);
      expect(cubit.state.hasValidRange, isTrue);
    });

    test('has no payment method yet, so confirmation is blocked', () {
      expect(cubit.state.method, isNull);
      expect(cubit.state.canConfirm, isFalse);
    });

    test('the visible month matches the start date', () {
      expect(cubit.state.visibleMonth.year, cubit.state.start!.year);
      expect(cubit.state.visibleMonth.month, cubit.state.start!.month);
    });
  });

  group('selectDay', () {
    test('a tap while a range is complete restarts the selection', () {
      final day = DateTime(2026, 8, 5);

      cubit.selectDay(day);

      expect(cubit.state.start, day);
      expect(cubit.state.end, isNull);
      expect(cubit.state.hasValidRange, isFalse);
    });

    test('a second, later tap completes the range', () {
      cubit.selectDay(DateTime(2026, 8, 5));
      cubit.selectDay(DateTime(2026, 8, 20));

      expect(cubit.state.start, DateTime(2026, 8, 5));
      expect(cubit.state.end, DateTime(2026, 8, 20));
      expect(cubit.state.hasValidRange, isTrue);
    });

    test('tapping before the start restarts from that day', () {
      cubit.selectDay(DateTime(2026, 8, 10));
      cubit.selectDay(DateTime(2026, 8, 3));

      expect(cubit.state.start, DateTime(2026, 8, 3));
      expect(cubit.state.end, isNull);
    });

    test(
      'tapping the start again restarts rather than making a zero range',
      () {
        cubit.selectDay(DateTime(2026, 8, 10));
        cubit.selectDay(DateTime(2026, 8, 10));

        expect(cubit.state.start, DateTime(2026, 8, 10));
        expect(cubit.state.end, isNull);
      },
    );
  });

  group('month paging', () {
    test('nextMonth advances the visible month', () {
      final before = cubit.state.visibleMonth;

      cubit.nextMonth();

      final after = cubit.state.visibleMonth;
      expect(
        after.year * 12 + after.month,
        before.year * 12 + before.month + 1,
      );
    });

    test('previousMonth steps back', () {
      final before = cubit.state.visibleMonth;

      cubit.previousMonth();

      final after = cubit.state.visibleMonth;
      expect(
        after.year * 12 + after.month,
        before.year * 12 + before.month - 1,
      );
    });

    test('paging across a year boundary rolls over correctly', () {
      while (cubit.state.visibleMonth.month != 12) {
        cubit.nextMonth();
      }
      final december = cubit.state.visibleMonth;

      cubit.nextMonth();

      expect(cubit.state.visibleMonth.month, 1);
      expect(cubit.state.visibleMonth.year, december.year + 1);
    });
  });

  group('payment method', () {
    test('choosing a method unblocks confirmation', () {
      cubit.chooseMethod(PaymentMethod.momo);

      expect(cubit.state.method, PaymentMethod.momo);
      expect(cubit.state.canConfirm, isTrue);
    });

    test('editMethod clears the choice and re-blocks confirmation', () {
      cubit.chooseMethod(PaymentMethod.card);
      cubit.editMethod();

      expect(cubit.state.method, isNull);
      expect(cubit.state.canConfirm, isFalse);
    });

    test('a method without a valid range still cannot confirm', () {
      cubit.selectDay(DateTime(2026, 8, 5)); // clears the end date
      cubit.chooseMethod(PaymentMethod.card);

      expect(cubit.state.canConfirm, isFalse);
    });

    test('every method has a label', () {
      expect(PaymentMethod.card.label, 'Credit or Debit card');
      expect(PaymentMethod.momo.label, 'Momo');
    });
  });
}
