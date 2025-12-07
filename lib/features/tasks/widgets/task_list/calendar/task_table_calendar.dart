import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/widgets/task_list/calendar/calendar_day_cell.dart';
import 'package:flip/theme/app_colors.dart';

class TaskTableCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat format;
  final List<TaskModel> Function(DateTime) getTasksForDay;
  final ValueChanged<DateTime> onFocusedDayChanged;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  const TaskTableCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.format,
    required this.getTasksForDay,
    required this.onFocusedDayChanged,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Số hàng: 5 hàng cho month view (thay vì 6)
          final rowCount = format == CalendarFormat.month ? 5 : 2;
          final daysOfWeekHeight = 40.0;
          // Tính chiều cao còn lại để chia đều cho các ô
          final availableHeight = constraints.maxHeight - daysOfWeekHeight;
          final cellHeight = availableHeight / rowCount;

          return SizedBox(
            height: constraints.maxHeight,
            child: TableCalendar<TaskModel>(
              locale: 'vi_VN',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              calendarFormat: format,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerVisible: false,
              daysOfWeekHeight: daysOfWeekHeight,
              rowHeight: cellHeight,
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) {
                return selectedDay != null &&
                    day.year == selectedDay!.year &&
                    day.month == selectedDay!.month &&
                    day.day == selectedDay!.day;
              },
              eventLoader: getTasksForDay,
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(fontSize: 14),
                outsideTextStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
                weekendTextStyle: const TextStyle(fontSize: 14),
                todayDecoration: BoxDecoration(
                  color: AppColors.xanh1.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.xanh1.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                outsideDaysVisible: true,
                cellMargin: EdgeInsets.zero,
                cellPadding: EdgeInsets.zero,
                // Tắt marker mặc định (cục đen đen)
                markerDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Colors.grey.shade800,
                ),
                weekendStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Colors.grey.shade800,
                ),
              ),
              onDaySelected: onDaySelected,
              onPageChanged: onFocusedDayChanged,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focused) {
                  final isSelected = _isSameDay(day, selectedDay);
                  final isToday = DateUtils.isSameDay(day, DateTime.now());
                  final isOutside = day.month != focusedDay.month;
                  return _buildDayCell(day, isSelected, isToday, isOutside);
                },
                selectedBuilder: (context, day, focused) {
                  final isOutside = day.month != focusedDay.month;
                  return _buildDayCell(day, true, false, isOutside);
                },
                todayBuilder: (context, day, focused) {
                  final isSelected = _isSameDay(day, selectedDay);
                  final isOutside = day.month != focusedDay.month;
                  return _buildDayCell(day, isSelected, true, isOutside);
                },
                outsideBuilder: (context, day, focused) {
                  final isSelected = _isSameDay(day, selectedDay);
                  return _buildDayCell(day, isSelected, false, true);
                },
                dowBuilder: (context, day) {
                  const labels = [
                    'CN',
                    'TH 2',
                    'TH 3',
                    'TH 4',
                    'TH 5',
                    'TH 6',
                    'TH 7',
                  ];
                  final text = labels[day.weekday % 7];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.vang.withOpacity(0.2),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.vang.withOpacity(0.7),
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    bool isSelected,
    bool isToday,
    bool isOutside,
  ) {
    final tasks = getTasksForDay(day);
    return CalendarDayCell(
      day: day,
      isSelected: isSelected,
      isToday: isToday,
      isOutside: isOutside,
      tasks: tasks,
    );
  }

  bool _isSameDay(DateTime a, DateTime? b) {
    return b != null &&
        a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}
