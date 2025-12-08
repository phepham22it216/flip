import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/chart_model.dart';

class StatusChartService {
  final TaskService _taskService = TaskService();

  /// Lấy task trong khoảng thời gian cho user hiện tại
  /// Nếu startDate/endDate null → lấy tất cả task
  Future<List<TaskModel>> getTasksInRange({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final allTasks = await _taskService.getTasksByUserId(user.uid).first;
    print('Current user UID: ${user.uid}');
    print('All tasks fetched from DB:${allTasks.length}');

    // Nếu startDate hoặc endDate null → trả về tất cả task active
    if (startDate == null || endDate == null) {
      return allTasks.where((task) => task.activity).toList();
    }

    return allTasks.where((task) {
      final taskStart = task.startTime;
      final taskEnd = task.endTime;

      // Task nằm trong khoảng nếu start hoặc end chồng lên range
      final isInRange = taskEnd.isAfter(startDate) && taskStart.isBefore(endDate);

      return isInRange && task.activity;
    }).toList();
  }

  /// Tính % Done / Pending / Overdue
  Future<List<ChartData>> calculateStatusPercent({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final tasks = await getTasksInRange(startDate: startDate, endDate: endDate);
    final now = DateTime.now();

    int doneCount = 0;
    int pendingCount = 0;
    int overdueCount = 0;

    for (var task in tasks) {
      if (task.status == 'completed') {
        doneCount++;
      } else if (task.status == 'inProgress' && task.endTime.isAfter(now)) {
        pendingCount++;
      } else if (task.status == 'inProgress' && task.endTime.isBefore(now)) {
        overdueCount++;
      }
    }

    final total = doneCount + pendingCount + overdueCount;

    // ⭐ Trường hợp KHÔNG có task nào → 1 vòng tròn xám
    if (total == 0) {
      return [
        ChartData("Không có dữ liệu", 100, Colors.grey.shade400, showLabel: false)
      ];
    }

    // ⭐ Tính %
    final donePercent = ((doneCount / total) * 100);
    final pendingPercent = ((pendingCount / total) * 100);
    final overduePercent = ((overdueCount / total) * 100);

    List<ChartData> data = [];

    if (donePercent > 0) {
      data.add(ChartData("Hoàn thành", donePercent.toDouble(), Colors.green));
    }
    if (pendingPercent > 0) {
      data.add(ChartData("Chưa xong", pendingPercent.toDouble(), Colors.orange));
    }
    if (overduePercent > 0) {
      data.add(ChartData("Quá hạn", overduePercent.toDouble(), Colors.red));
    }

    return data;
  }


}
