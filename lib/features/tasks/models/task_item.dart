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
    );
  }
}
