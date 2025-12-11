import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/chart_model.dart';

class AvgTimeResult {
  final List<ChartData> chartData; // percentage per category
  final Map<String, List<String>> tasksByCategory; // names per category
  final Map<String, double> taskDurations; // taskName -> minutes
  final DateTime startDate;
  final DateTime endDate;

  AvgTimeResult({
    required this.chartData,
    required this.tasksByCategory,
    required this.taskDurations,
    required this.startDate,
    required this.endDate,
  });
}

class AvgTimeChartService {
  final TaskService _taskService = TaskService();

  Future<List<TaskModel>> _getTasksInRange({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final allTasks = await _taskService.getTasksByUserId(user.uid).first;

    if (startDate == null || endDate == null) {
      return allTasks.where((t) => t.activity).toList();
    }

    return allTasks.where((task) {
      final ts = task.startTime;
      final te = task.endTime;
      final overlap = te.isAfter(startDate) && ts.isBefore(endDate);
      return overlap && task.activity;
    }).toList();
  }

  /// Tính dữ liệu cho AvgTimeChart
  /// - Nếu startDate/endDate là null thì mặc định sẽ dùng NGÀY HÔM NAY (nguyên ngày).
  Future<AvgTimeResult> calculateAvgTimeData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // ========== MẶC ĐỊNH NGÀY NGUYÊN HÔM NAY ==========
    // Nếu startDate/endDate null => thiết lập start = 00:00:00 của hôm nay,
    // end = 23:59:59.999 của hôm nay.
    final now = DateTime.now();
    final defaultStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final defaultEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final sDate = startDate ?? defaultStart;
    final eDate = endDate ?? defaultEnd;
    // =================================================

    print("AvgTimeChartService: Using date range:");
    print("  startDate (default if null): $sDate");
    print("  endDate   (default if null): $eDate");

    final tasks = await _getTasksInRange(startDate: sDate, endDate: eDate);

    print("Total tasks fetched in range: ${tasks.length}");

    // Categories
    final categories = [
      '<10 phút',
      '10-30 phút',
      '30 phút-1 tiếng',
      '1-3 tiếng',
      '>3 tiếng',
      'Chưa hoàn thành'
    ];

    // prepare containers
    final Map<String, List<String>> tasksByCategory = {
      for (var c in categories) c: []
    };
    final Map<String, double> taskDurations = {}; // taskName -> minutes
    final Map<String, int> counts = {for (var c in categories) c: 0};

    // Iterate tasks
    final DateTime referenceNow = DateTime.now();
    for (var t in tasks) {
      final name = t.title ?? '(No title)';
      final ts = t.startTime;
      final te = t.endTime;

      print("Task: $name");
      print("  startTime: $ts");
      print("  endTime:   $te");
      // Determine duration:
      double minutes = 0;
      if (t.status == 'completed') {
        // Completed: total time = end - start
        minutes = te.difference(ts).inMinutes.toDouble();
      } else if (t.status == 'inProgress') {
        // InProgress: treat as "chưa hoàn thành"
        // For printing total time so far we use now - startTime
        minutes = referenceNow.difference(ts).inMinutes.toDouble();
      } else {
        // Other statuses: if present, we ignore or treat as not completed.
        minutes = te.difference(ts).inMinutes.toDouble();
      }

      // ensure non-negative
      if (minutes < 0) minutes = 0;

      taskDurations[name] = minutes;
      print("  computed duration (minutes): $minutes");

      if (t.status == 'inProgress') {
        counts['Chưa hoàn thành'] = counts['Chưa hoàn thành']! + 1;
        tasksByCategory['Chưa hoàn thành']!.add(name);
      } else if (t.status == 'completed') {
        // bucket by minutes
        if (minutes < 10) {
          counts['<10 phút'] = counts['<10 phút']! + 1;
          tasksByCategory['<10 phút']!.add(name);
        } else if (minutes >= 10 && minutes <= 30) {
          counts['10-30 phút'] = counts['10-30 phút']! + 1;
          tasksByCategory['10-30 phút']!.add(name);
        } else if (minutes > 30 && minutes <= 60) {
          counts['30 phút-1 tiếng'] = counts['30 phút-1 tiếng']! + 1;
          tasksByCategory['30 phút-1 tiếng']!.add(name);
        } else if (minutes > 60 && minutes <= 180) {
          counts['1-3 tiếng'] = counts['1-3 tiếng']! + 1;
          tasksByCategory['1-3 tiếng']!.add(name);
        } else {
          counts['>3 tiếng'] = counts['>3 tiếng']! + 1;
          tasksByCategory['>3 tiếng']!.add(name);
        }
      } else {
        // if other status, put into 'Chưa hoàn thành' by default
        counts['Chưa hoàn thành'] = counts['Chưa hoàn thành']! + 1;
        tasksByCategory['Chưa hoàn thành']!.add(name);
      }
    }

    // Print category totals and names
    print("=== Category totals & tasks ===");
    int grandTotal = 0;
    for (var c in categories) {
      final ct = counts[c]!;
      grandTotal += ct;
      print("Category: $c  -> count: $ct");
      final names = tasksByCategory[c]!;
      if (names.isEmpty) {
        print("  (no tasks)");
      } else {
        for (var n in names) print("  - $n");
      }
    }

    // Build chart data as percentage of grandTotal
    final List<ChartData> chartData = [];
    if (grandTotal == 0) {
      // no data -> return zeros (upper layer widget can detect empty lists)
      // But still return empty chartData to show empty chart
      print("No tasks in range -> returning empty chart data");
      return AvgTimeResult(
        chartData: [],
        tasksByCategory: tasksByCategory,
        taskDurations: taskDurations,
        startDate: sDate,
        endDate: eDate,
      );
    }

    // For each category compute percent (value between 0..100)
    for (var c in categories) {
      final ct = counts[c]!;
      if (ct > 0) {
        final percent = (ct / grandTotal) * 100;
        // pick color consistent with widget
        Color color;
        switch (c) {
          case '<10 phút':
            color = Colors.green;
            break;
          case '10-30 phút':
            color = Colors.yellow;
            break;
          case '30 phút-1 tiếng':
            color = Colors.orange;
            break;
          case '1-3 tiếng':
            color = Colors.red;
            break;
          case '>3 tiếng':
            color = Colors.purple;
            break;
          case 'Chưa hoàn thành':
          default:
            color = Colors.grey;
            break;
        }
        chartData.add(ChartData(c, percent.toDouble(), color));
      }
    }

    print("=== Chart percentages ===");
    for (var d in chartData) {
      print("  ${d.label} -> ${d.value.toStringAsFixed(2)}%");
    }

    return AvgTimeResult(
      chartData: chartData,
      tasksByCategory: tasksByCategory,
      taskDurations: taskDurations,
      startDate: sDate,
      endDate: eDate,
    );
  }
}
