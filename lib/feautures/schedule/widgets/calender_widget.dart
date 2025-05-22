import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../styles/schedule_styles.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _currentDateTime = DateTime.now();
  DateTime? _selectedDateTime;

  void _nextMonth() {
    setState(() {
      _currentDateTime = DateTime(_currentDateTime.year, _currentDateTime.month + 1);
    });
  }

  void _previousMonth() {
    setState(() {
      _currentDateTime = DateTime(_currentDateTime.year, _currentDateTime.month - 1);
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDateTime = day;
    });
    // Anda bisa menambahkan logika lain di sini, seperti menampilkan event untuk hari yang dipilih
    print('Selected day: ${DateFormat('yyyy-MM-dd').format(day)}');
  }

  List<DateTime> _getDaysInMonth() {
    final firstDayOfMonth = DateTime(_currentDateTime.year, _currentDateTime.month, 1);
    final lastDayOfMonth = DateTime(_currentDateTime.year, _currentDateTime.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final firstDayOfWeek = firstDayOfMonth.weekday; // 1 for Monday, 7 for Sunday
    final daysBefore = firstDayOfWeek == 7 ? 0 : firstDayOfWeek; // Adjust for Sunday as first day

    final List<DateTime> days = [];
    // Add padding for days before the first day of the month
    for (int i = 0; i < daysBefore; i++) {
      days.add(DateTime(_currentDateTime.year, _currentDateTime.month, 1 - (daysBefore - i)));
    }
    // Add days of the current month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_currentDateTime.year, _currentDateTime.month, i));
    }
    // Add padding for days after the last day of the month
    final daysAfter = 7 - (daysBefore + daysInMonth) % 7;
    if (daysAfter < 7) {
      for (int i = 1; i <= daysAfter; i++) {
        days.add(DateTime(_currentDateTime.year, _currentDateTime.month + 1, i));
      }
    }
    return days;
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: daysInMonth.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemBuilder: (context, index) {
        final day = daysInMonth[index];
        final isCurrentMonth = day.month == _currentDateTime.month;
        final isToday = day.year == DateTime.now().year &&
            day.month == DateTime.now().month &&
            day.day == DateTime.now().day;
        final isSelected = _selectedDateTime != null &&
            day.year == _selectedDateTime!.year &&
            day.month == _selectedDateTime!.month &&
            day.day == _selectedDateTime!.day;

        return GestureDetector(
          onTap: isCurrentMonth ? () => _selectDay(day) : null,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE6F0FF)
                  : isToday && isCurrentMonth
                      ? Colors.grey[200]
                      : null,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  DateFormat('d').format(day),
                  style: TextStyle(
                    color: isSelected
                        ? ScheduleStyles.selectedDayStyle.color
                        : isCurrentMonth
                            ? (isToday ? Colors.blue[800] : ScheduleStyles.dayStyle.color)
                            : Colors.grey,
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 358),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_currentDateTime),
                      style: ScheduleStyles.monthStyle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Weekday Labels
                Row(
                  children: [
                    _buildWeekdayLabel('Sun'),
                    _buildWeekdayLabel('Mon'),
                    _buildWeekdayLabel('Tue'),
                    _buildWeekdayLabel('Wed'),
                    _buildWeekdayLabel('Thu'),
                    _buildWeekdayLabel('Fri'),
                    _buildWeekdayLabel('Sat'),
                  ],
                ),
                const SizedBox(height: 8),
                // Calendar Grid
                _buildCalendarGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabel(String label) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: ScheduleStyles.weekdayStyle,
        ),
      ),
    );
  }
}