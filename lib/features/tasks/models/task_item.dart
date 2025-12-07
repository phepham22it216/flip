import 'package:flutter/material.dart';

class TaskItem {
  final String id;
  final String title;
  final String subtitle;
  final int percent;
  final String durationText;
  final Color color;
  final DateTime startTime;
  final DateTime endTime;
  final int priority; // 1: Low, 2: Medium, 3: High
  final int difficulty; // 1: Easy, 2: Medium, 3: Hard
  final bool isDone;
  final String groupName;
  final List<String> reminders; // e.g., ['5 phút trước', '1 giờ trước']
  final bool reminderEnabled;
  final String? repeatText; // e.g., 'Mỗi 4 Thứ Bảy'
  final DateTime? repeatEndDate;
  final bool pinned;

  TaskItem({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.percent = 0,
    this.durationText = '',
    required this.color,
    required this.startTime,
    required this.endTime,
    this.priority = 2,
    this.difficulty = 2,
    this.isDone = false,
    this.groupName = '',
    this.reminders = const [],
    this.reminderEnabled = true,
    this.repeatText,
    this.repeatEndDate,
    this.pinned = false,
  });

  /// Creates a copy of this TaskItem but with the given fields replaced with the new values.
  TaskItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? percent,
    String? durationText,
    Color? color,
    DateTime? startTime,
    DateTime? endTime,
    int? priority,
    int? difficulty,
    bool? isDone,
    String? groupName,
    List<String>? reminders,
    bool? reminderEnabled,
    String? repeatText,
    DateTime? repeatEndDate,
    bool? pinned,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      percent: percent ?? this.percent,
      durationText: durationText ?? this.durationText,
      color: color ?? this.color,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      priority: priority ?? this.priority,
      difficulty: difficulty ?? this.difficulty,
      isDone: isDone ?? this.isDone,
      groupName: groupName ?? this.groupName,
      reminders: reminders ?? this.reminders,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      repeatText: repeatText ?? this.repeatText,
      repeatEndDate: repeatEndDate ?? this.repeatEndDate,
      pinned: pinned ?? this.pinned,
    );
  }
}
