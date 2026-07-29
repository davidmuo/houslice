import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

/// Custom month calendar with range selection, matching the Figma booking
/// calendar (Sun-first grid, orange endpoints, soft-orange in-between days).
/// All state lives outside the widget (in a cubit) so it stays stateless.
class AppCalendar extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const AppCalendar({
    super.key,
    required this.visibleMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onDaySelected,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    // Number of leading cells from the previous month (Sunday-first grid).
    final lead = firstOfMonth.weekday % 7;
    final gridStart = firstOfMonth.subtract(Duration(days: lead));

    return Column(
      children: [
        Row(
          children: [
            // The month label yields to the nav buttons rather than pushing
            // them off the edge on narrow screens.
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(visibleMonth),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
            _NavButton(icon: Icons.chevron_left, onTap: onPrevMonth),
            const SizedBox(width: 10),
            _NavButton(icon: Icons.chevron_right, onTap: onNextMonth),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final day in _weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const Divider(height: 20),
        for (var week = 0; week < 6; week++)
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: _DayCell(
                    day: gridStart.add(Duration(days: week * 7 + i)),
                    visibleMonth: visibleMonth,
                    rangeStart: rangeStart,
                    rangeEnd: rangeEnd,
                    onTap: onDaySelected,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.dark, width: 1.4),
        ),
        child: Icon(icon, size: 20, color: AppColors.dark),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final DateTime visibleMonth;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final ValueChanged<DateTime> onTap;

  const _DayCell({
    required this.day,
    required this.visibleMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onTap,
  });

  bool _sameDay(DateTime? a, DateTime b) =>
      a != null && a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final inMonth = day.month == visibleMonth.month;
    final isStart = _sameDay(rangeStart, day);
    final isEnd = _sameDay(rangeEnd, day);
    final inRange =
        rangeStart != null &&
        rangeEnd != null &&
        day.isAfter(rangeStart!) &&
        day.isBefore(rangeEnd!);

    Color? bg;
    Color fg = inMonth ? AppColors.dark : AppColors.grey;
    if (isStart || isEnd) {
      bg = AppColors.primary;
      fg = Colors.white;
    } else if (inRange) {
      bg = AppColors.primarySoft;
      fg = AppColors.dark;
    }

    return AspectRatio(
      aspectRatio: 1.2,
      child: InkWell(
        onTap: () => onTap(DateTime(day.year, day.month, day.day)),
        customBorder: const CircleBorder(),
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            decoration: bg == null
                ? null
                : BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: fg,
                fontWeight: isStart || isEnd
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
