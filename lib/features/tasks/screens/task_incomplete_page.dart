import 'package:flip/features/tasks/models/task_item.dart';
import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/features/tasks/widgets/task_incomplete/statistics_card.dart';
import 'package:flip/features/tasks/widgets/task_incomplete/filter_tabs.dart';
import 'package:flip/features/tasks/widgets/task_incomplete/date_section.dart';
import 'package:flip/features/tasks/widgets/task_incomplete/empty_state.dart';

class TaskIncompletePage extends StatefulWidget {
  const TaskIncompletePage({super.key});

  @override
  State<TaskIncompletePage> createState() => _TaskIncompletePageState();
}

class _TaskIncompletePageState extends State<TaskIncompletePage> {
  TaskFilter _selectedFilter = TaskFilter.all;

  // Mock data - Replace with actual data from your service
  final List<TaskItem> _allTasks = [
    TaskItem(
      id: '1',
      title: "Reading",
      subtitle: "Đọc sách tài liệu liên quan đến Flutter và Dart",
      percent: 0,
      durationText: "00:00:00",
      color: AppColors.hong,
      startTime: DateTime.now().copyWith(hour: 8, minute: 0),
      endTime: DateTime.now().copyWith(hour: 10, minute: 0),
      priority: 2,
      difficulty: 1,
      isDone: false,
      groupName: 'Học tập',
      pinned: true,
    ),
    TaskItem(
      id: '2',
      title: "Học Đa Nền Tảng",
      subtitle: "Hoàn thành các bài tập thực hành trong lớp học",
      percent: 50,
      durationText: "02:30:00",
      color: AppColors.tim1,
      startTime: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 9),
      endTime: DateTime.now()
          .add(const Duration(days: 1))
          .copyWith(hour: 11, minute: 30),
      priority: 3,
      difficulty: 2,
      isDone: false,
      groupName: 'Lớp học',
    ),
    TaskItem(
      id: '3',
      title: "Làm bài tập Flutter",
      subtitle: "Hoàn thành project todo app với Firebase",
      percent: 30,
      durationText: "01:15:00",
      color: AppColors.cam,
      startTime: DateTime.now()
          .subtract(const Duration(days: 2))
          .copyWith(hour: 14),
      endTime: DateTime.now()
          .subtract(const Duration(days: 2))
          .copyWith(hour: 15, minute: 15),
      priority: 3,
      difficulty: 3,
      isDone: false,
      groupName: 'Project',
    ),
    TaskItem(
      id: '4',
      title: "Học Java",
      subtitle: "Ôn tập các kiến thức về Java OOP",
      percent: 75,
      durationText: "03:45:00",
      color: AppColors.xanh2,
      startTime: DateTime.now().add(const Duration(days: 3)).copyWith(hour: 13),
      endTime: DateTime.now()
          .add(const Duration(days: 3))
          .copyWith(hour: 16, minute: 45),
      priority: 2,
      difficulty: 2,
      isDone: false,
      groupName: 'Lập trình',
    ),
    TaskItem(
      id: '5',
      title: "Meeting Team",
      subtitle: "Thảo luận về dự án mới",
      percent: 0,
      durationText: "00:00:00",
      color: AppColors.xanhLa1,
      startTime: DateTime.now()
          .subtract(const Duration(days: 1))
          .copyWith(hour: 15),
      endTime: DateTime.now()
          .subtract(const Duration(days: 1))
          .copyWith(hour: 16),
      priority: 3,
      difficulty: 1,
      isDone: false,
      groupName: 'Team',
    ),
  ];

  List<TaskItem> get _filteredTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    switch (_selectedFilter) {
      case TaskFilter.today:
        return _allTasks.where((task) {
          final taskDate = DateTime(
            task.startTime.year,
            task.startTime.month,
            task.startTime.day,
          );
          return !task.isDone && taskDate.isAtSameMomentAs(today);
        }).toList();
      case TaskFilter.overdue:
        return _allTasks.where((task) {
          final taskDate = DateTime(
            task.startTime.year,
            task.startTime.month,
            task.startTime.day,
          );
          return !task.isDone && taskDate.isBefore(today);
        }).toList();
      case TaskFilter.upcoming:
        return _allTasks.where((task) {
          final taskDate = DateTime(
            task.startTime.year,
            task.startTime.month,
            task.startTime.day,
          );
          return !task.isDone && taskDate.isAfter(today);
        }).toList();
      case TaskFilter.all:
      default:
        return _allTasks.where((task) => !task.isDone).toList();
    }
  }

  int get _overdueCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allTasks.where((task) {
      final taskDate = DateTime(
        task.startTime.year,
        task.startTime.month,
        task.startTime.day,
      );
      return !task.isDone && taskDate.isBefore(today);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Công việc chưa hoàn thành',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Statistics Card
          StatisticsCard(tasks: _allTasks, overdueCount: _overdueCount),

          // Filter Tabs
          FilterTabs(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),

          // Task List
          Expanded(
            child: filteredTasks.isEmpty
                ? EmptyState(selectedFilter: _selectedFilter)
                : _buildTaskList(filteredTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskItem> tasks) {
    // Group tasks by date
    final groupedTasks = <DateTime, List<TaskItem>>{};
    for (final task in tasks) {
      final date = DateTime(
        task.startTime.year,
        task.startTime.month,
        task.startTime.day,
      );
      groupedTasks.putIfAbsent(date, () => []).add(task);
    }

    final sortedDates = groupedTasks.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final tasksForDate = groupedTasks[date]!;
        return DateSection(date: date, tasks: tasksForDate);
      },
    );
  }
}
