import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_calendar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/booking_form_cubit.dart';

/// "Select Date" bottom sheet with the range calendar from the Figma design.
Future<void> showSelectDateSheet(
  BuildContext context,
  BookingFormCubit cubit,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => BlocProvider.value(
      value: cubit,
      child: const _SelectDateSheet(),
    ),
  );
}

class _SelectDateSheet extends StatelessWidget {
  const _SelectDateSheet();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: BlocBuilder<BookingFormCubit, BookingFormState>(
          builder: (context, state) {
            final cubit = context.read<BookingFormCubit>();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Select Date',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryFaint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.calendar_month_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calendar',
                          style: textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Set time on your calendar',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 28),
                AppCalendar(
                  visibleMonth: state.visibleMonth,
                  rangeStart: state.start,
                  rangeEnd: state.end,
                  onDaySelected: cubit.selectDay,
                  onPrevMonth: cubit.previousMonth,
                  onNextMonth: cubit.nextMonth,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Save',
                  onPressed: state.hasValidRange
                      ? () => Navigator.of(context).pop()
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
