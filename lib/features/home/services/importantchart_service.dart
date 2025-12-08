import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImportantChartService {
  final TaskService _taskService = TaskService();

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
      final taskStart = task.startTime;
      final taskEnd = task.endTime;

      final isInRange = taskEnd.isAfter(startDate) && taskStart.isBefore(endDate);

      return isInRange && task.activity;
    }).toList();
  }

  /// ⭐ Trả về: số lượng 3 mức ưu tiên (1–2–3)
  Future<Map<String, int>> calculatePriorityCount({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final tasks = await getTasksInRange(startDate: startDate, endDate: endDate);

    int low = 0;      // priority = 1
    int medium = 0;   // priority = 2
    int high = 0;     // priority = 3

    for (var task in tasks) {
      if (task.priority == 1) {
        low++;
      } else if (task.priority == 2) {
        medium++;
      } else if (task.priority == 3) {
        high++;
      }
    }

    return {
      "low": low,
      "medium": medium,
      "high": high,
    };
  }
}
