import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:flip/theme/app_colors.dart';
import 'package:flip/features/tasks/models/task_item.dart';
import 'package:flip/features/tasks/widgets/calendar_header.dart';
import 'package:flip/features/tasks/widgets/calendar_view_mode.dart';
import 'package:flip/features/tasks/widgets/task_day_timeline.dart';
import 'package:flip/features/tasks/widgets/task_table_calendar.dart';
import 'package:flip/features/tasks/widgets/week_time_table.dart';

class TaskCalendarPage extends StatefulWidget {
  final List<TaskItem> tasks;

  const TaskCalendarPage({super.key, required this.tasks});

  @override
  State<TaskCalendarPage> createState() => _TaskCalendarPageState();
}

class _TaskCalendarPageState extends State<TaskCalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarViewMode _viewMode = CalendarViewMode.month;

  /// Map ngày (yyyy-MM-dd) -> danh sách task của ngày đó
  late final Map<DateTime, List<TaskItem>> _tasksByDate;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
    _tasksByDate = _groupTasksByDate(widget.tasks);
  }

  Map<DateTime, List<TaskItem>> _groupTasksByDate(List<TaskItem> tasks) {
    final map = <DateTime, List<TaskItem>>{};
    for (final task in tasks) {
      final key = DateTime(
        task.startTime.year,
        task.startTime.month,
        task.startTime.day,
      );
      map.putIfAbsent(key, () => []).add(task);
    }
    return map;
  }

  List<TaskItem> _getTasksForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _tasksByDate[key] ?? [];
  }

  void _onPrev() {
    setState(() {
      switch (_viewMode) {
        case CalendarViewMode.month:
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
          break;
        case CalendarViewMode.week:
          _focusedDay = _focusedDay.subtract(const Duration(days: 7));
          break;
        case CalendarViewMode.day:
          _focusedDay = _focusedDay.subtract(const Duration(days: 1));
          _selectedDay = _focusedDay;
          break;
      }
    });
  }

  void _onNext() {
    setState(() {
      switch (_viewMode) {
        case CalendarViewMode.month:
          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
          break;
        case CalendarViewMode.week:
          _focusedDay = _focusedDay.add(const Duration(days: 7));
          break;
        case CalendarViewMode.day:
          _focusedDay = _focusedDay.add(const Duration(days: 1));
          _selectedDay = _focusedDay;
          break;
      }
    });
  }

  String _buildHeaderLabel() {
    switch (_viewMode) {
      case CalendarViewMode.day:
        return DateFormat('EEE, dd/MM/yyyy', 'vi_VN').format(_focusedDay);
      case CalendarViewMode.week:
        final startOfWeek = _focusedDay.subtract(
          Duration(days: _focusedDay.weekday % 7),
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final df = DateFormat('dd/MM', 'vi_VN');
        final mf = DateFormat('MM/yyyy', 'vi_VN');
        return '${df.format(startOfWeek)} - ${df.format(endOfWeek)} '
            '(${mf.format(_focusedDay)})';
      case CalendarViewMode.month:
        return DateFormat('MMMM yyyy', 'vi_VN').format(_focusedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CalendarHeader(
              headerLabel: _buildHeaderLabel(),
              viewMode: _viewMode,
              onViewModeChanged: (mode) {
                setState(() {
                  _viewMode = mode;
                });
              },
              onPrev: _onPrev,
              onNext: _onNext,
            ),
            const SizedBox(height: 4),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_viewMode) {
      case CalendarViewMode.day:
        return _buildDayView();
      case CalendarViewMode.week:
        // Lấy ngày đầu tuần (thứ 2)
        final startOfWeek = _focusedDay.subtract(
          Duration(days: (_focusedDay.weekday - 1) % 7),
        );
        return WeekTimeTable(weekStart: startOfWeek, tasks: widget.tasks);
      case CalendarViewMode.month:
        return _buildTableCalendar(format: CalendarFormat.month);
    }
  }

  Widget _buildDayView() {
    final day = _selectedDay ?? _focusedDay;
    final tasks = _getTasksForDay(day);
    return TaskDayTimeline(day: day, tasks: tasks);
  }

  Widget _buildTableCalendar({required CalendarFormat format}) {
    return TaskTableCalendar(
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      format: format,
      getTasksForDay: _getTasksForDay,
      onFocusedDayChanged: (day) {
        setState(() {
          _focusedDay = day;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = DateTime(
            selectedDay.year,
            selectedDay.month,
            selectedDay.day,
          );
          _focusedDay = focusedDay;
        });
      },
    );
  }
}
