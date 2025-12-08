import 'package:flutter/material.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/models/task_constants.dart';

class TaskUtils {
  /// Nhóm các task theo quadrant
  static Map<String, List<TaskModel>> groupTasksByQuadrant(
    List<TaskModel> tasks,
  ) {
    final map = <String, List<TaskModel>>{
      TaskConstants.quadrantDoFirst: [],
      TaskConstants.quadrantSchedule: [],
      TaskConstants.quadrantDelegate: [],
      TaskConstants.quadrantEliminate: [],
    };
    for (final task in tasks) {
      final quadrant = task.matrixQuadrant ?? _getQuadrantFromColor(task.color);
      if (map.containsKey(quadrant)) {
        map[quadrant]!.add(task);
      } else {
        map[TaskConstants.quadrantEliminate]!.add(task);
      }
    }
    return map;
  }

  /// Lấy quadrant từ màu của task
  static String _getQuadrantFromColor(Color color) {
    if (color.value == TaskConstants.colorDoFirst.value) {
      return TaskConstants.quadrantDoFirst;
    }
    if (color.value == TaskConstants.colorSchedule.value) {
      return TaskConstants.quadrantSchedule;
    }
    if (color.value == TaskConstants.colorDelegate.value) {
      return TaskConstants.quadrantDelegate;
    }
    if (color.value == TaskConstants.colorEliminate.value) {
      return TaskConstants.quadrantEliminate;
    }
    return TaskConstants.quadrantEliminate;
  }

  /// Kiểm tra xem task có phải hôm nay không
  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }
}
