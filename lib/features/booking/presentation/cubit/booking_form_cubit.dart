import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PaymentMethod { card, momo }

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.card => 'Credit or Debit card',
    PaymentMethod.momo => 'Momo',
  };
}

/// Local checkout state for a single booking flow: the selected stay range,
/// the calendar's visible month and the chosen payment method.
class BookingFormState extends Equatable {
  final DateTime? start;
  final DateTime? end;
  final DateTime visibleMonth;
  final PaymentMethod? method;

  const BookingFormState({
    this.start,
    this.end,
    required this.visibleMonth,
    this.method,
  });

  bool get hasValidRange =>
      start != null && end != null && end!.isAfter(start!);

  bool get canConfirm => hasValidRange && method != null;

  BookingFormState copyWith({
    DateTime? start,
    DateTime? end,
    DateTime? visibleMonth,
    PaymentMethod? method,
    bool clearEnd = false,
    bool clearMethod = false,
  }) => BookingFormState(
    start: start ?? this.start,
    end: clearEnd ? null : (end ?? this.end),
    visibleMonth: visibleMonth ?? this.visibleMonth,
    method: clearMethod ? null : (method ?? this.method),
  );

  @override
  List<Object?> get props => [start, end, visibleMonth, method];
}

class BookingFormCubit extends Cubit<BookingFormState> {
  BookingFormCubit._(super.initial);

  factory BookingFormCubit() {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 7));
    return BookingFormCubit._(
      BookingFormState(
        start: start,
        end: start.add(const Duration(days: 31)),
        visibleMonth: DateTime(start.year, start.month),
      ),
    );
  }

  /// First tap picks the start, second tap the end; tapping before the
  /// start (or when a range is complete) restarts the selection.
  void selectDay(DateTime day) {
    final start = state.start;
    final end = state.end;
    if (start == null || end != null || !day.isAfter(start)) {
      emit(state.copyWith(start: day, clearEnd: true));
    } else {
      emit(state.copyWith(end: day));
    }
  }

  void previousMonth() => emit(
    state.copyWith(
      visibleMonth: DateTime(
        state.visibleMonth.year,
        state.visibleMonth.month - 1,
      ),
    ),
  );

  void nextMonth() => emit(
    state.copyWith(
      visibleMonth: DateTime(
        state.visibleMonth.year,
        state.visibleMonth.month + 1,
      ),
    ),
  );

  void chooseMethod(PaymentMethod method) =>
      emit(state.copyWith(method: method));

  void editMethod() => emit(state.copyWith(clearMethod: true));
}
