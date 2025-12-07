// Test case demonstration for TaskEditPage with sample data

import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/theme/app_colors.dart';

void testEditTaskFlow() {
  // Sample task data with reminders and repeat settings
  // ignore: unused_local_variable
  final testTask = TaskModel(
    id: '1',
    title: "Reading",
    subtitle: "Đọc sách tài liệu liên quan đến Flutter và Dart",
    percent: 0,
    color: AppColors.hong,
    startTime: DateTime(2024, 12, 23, 8, 0),
    endTime: DateTime(2024, 12, 23, 10, 0),
    priority: 2,
    difficulty: 1,
    isDone: false,
    groupName: 'Học tập',
    // Reminder fields
    reminders: ['5 phút trước'], // Display reminder time
    reminderEnabled: true,
    // Repeat fields
    repeatText: 'Mỗi 4 Thứ Bảy', // Display repeat pattern
    repeatEndDate: DateTime(2025, 3, 31), // End date for repeat
    pinned: true,
  );
}
