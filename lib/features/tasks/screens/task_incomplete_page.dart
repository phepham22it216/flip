import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TaskService _taskService = TaskService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TaskModel> _filterTasks(List<TaskModel> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case TaskFilter.today:
        return allTasks.where((task) {
          final taskDate = DateTime(
            task.startTime.year,
            task.startTime.month,
            task.startTime.day,
          );
          return !task.isDone && taskDate.isAtSameMomentAs(today);
        }).toList();
      case TaskFilter.overdue:
        return allTasks.where((task) {
          final taskDate = DateTime(
            task.startTime.year,
            task.startTime.month,
            task.startTime.day,
          );
          return !task.isDone && taskDate.isBefore(today);
        }).toList();
      case TaskFilter.upcoming:
        return allTasks.where((task) {
          final taskDate = DateTime(
            task.startTime.year,
            task.startTime.month,
            task.startTime.day,
          );
          return !task.isDone && taskDate.isAfter(today);
        }).toList();
      case TaskFilter.all:
        return allTasks.where((task) => !task.isDone).toList();
    }
  }

  int _getOverdueCount(List<TaskModel> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allTasks.where((task) {
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
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Công việc chưa hoàn thành'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Vui lòng đăng nhập để xem công việc')),
      );
    }

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
      body: StreamBuilder<List<TaskModel>>(
        stream: _taskService.getTasksByUserId(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final allTasks = snapshot.data ?? [];
          final filteredTasks = _filterTasks(allTasks);
          final overdueCount = _getOverdueCount(allTasks);

          return Column(
            children: [
              // Statistics Card
              StatisticsCard(tasks: allTasks, overdueCount: overdueCount),

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
          );
        },
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    // Group tasks by date
    final groupedTasks = <DateTime, List<TaskModel>>{};
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
