import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/chart_model.dart';

class RateChartService {
  final TaskService _taskService = TaskService();

  /// Lấy task trong khoảng thời gian
  Future<List<TaskModel>> getTasksInRange({
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
      final start = task.startTime;
      final end = task.endTime;

      final overlaps = end.isAfter(startDate) && start.isBefore(endDate);

      return overlaps && task.activity;
    }).toList();
  }

  /// Tính số lượng task theo độ khó
  Future<List<ChartData>> calculateDifficultyCount({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final tasks = await getTasksInRange(startDate: startDate, endDate: endDate);

    int easy = 0;     // difficulty = 1
    int medium = 0;   // difficulty = 2
    int hard = 0;     // difficulty = 3

    for (var t in tasks) {
      if (t.difficulty == 1) easy++;
      else if (t.difficulty == 2) medium++;
      else if (t.difficulty == 3) hard++;
    }

    // Không có dữ liệu → trả về danh sách rỗng để biểu đồ hiển thị trục trống
    if (easy == 0 && medium == 0 && hard == 0) {
      return [];
    }

    return [
      if (easy > 0) ChartData("Dễ", easy.toDouble(), Colors.blue),
      if (medium > 0) ChartData("Vừa", medium.toDouble(), Colors.purple),
      if (hard > 0) ChartData("Khó", hard.toDouble(), Colors.black),
    ];
  }
}
