import 'package:flutter/material.dart';
import 'package:flip/features/tasks/models/task_constants.dart';

class TaskModel {
  final String id;
  final String title;
  final String subtitle;
  final int percent;
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

  TaskModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.percent = 0,
    required this.color,
    required this.startTime,
    required this.endTime,
    this.priority = TaskConstants.defaultPriority,
    this.difficulty = TaskConstants.defaultDifficulty,
    this.isDone = false,
    this.groupName = '',
    this.reminders = const [],
    this.reminderEnabled = TaskConstants.defaultReminderEnabled,
    this.repeatText,
    this.repeatEndDate,
    this.pinned = TaskConstants.defaultPinned,
  });

  TaskModel copyWith({
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
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      percent: percent ?? this.percent,
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

  /// Map để lưu lên Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': subtitle,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'status': isDone
          ? TaskConstants.statusCompleted
          : TaskConstants.statusInProgress,
      'matrixQuadrant': _getQuadrantFromColor(),
      'priority': priority,
      'difficulty': difficulty,
      'type': _isGroupMode
          ? TaskConstants.typeGroup
          : TaskConstants.typePersonal,
      'groupName': groupName,
      'percent': percent,
      'reminders': reminders,
      'reminderEnabled': reminderEnabled,
      'repeatText': repeatText,
      'repeatEndDate': repeatEndDate?.millisecondsSinceEpoch,
      'pinned': pinned,
      // timestamp server (khi set/update ở service)
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };
  }

  bool get _isGroupMode => groupName.isNotEmpty;

  /// Tính duration khi hiển thị
  String get durationText {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';
  }

  /// Tạo TaskModel từ data Realtime Database
  factory TaskModel.fromMap(Map<String, dynamic> data, String docId) {
    // Mapping matrixQuadrant sang màu (sử dụng TaskConstants)
    Color getColorFromQuadrant(String? quadrant) {
      if (quadrant == null) return TaskConstants.colorEliminate;
      return TaskConstants.getColorFromQuadrant(quadrant);
    }

    int getPriority(dynamic value) {
      if (value is int) return value;
      if (value is String)
        return int.tryParse(value) ?? TaskConstants.defaultPriority;
      return TaskConstants.defaultPriority;
    }

    int getDifficulty(dynamic value) {
      if (value is int) return value;
      if (value is String)
        return int.tryParse(value) ?? TaskConstants.defaultDifficulty;
      return TaskConstants.defaultDifficulty;
    }

    DateTime parseMs(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is double) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      }
      return DateTime.now();
    }

    final startTime = parseMs(data['startTime']);
    final endTime = parseMs(data['endTime']);
    final status = data['status'] ?? TaskConstants.statusPending;
    final isDone = status == TaskConstants.statusCompleted;

    final rawReminders = data['reminders'];
    final reminders = rawReminders is List
        ? rawReminders.map((e) => e.toString()).toList()
        : <String>[];

    final repeatEndMs = data['repeatEndDate'];

    return TaskModel(
      id: docId,
      title: data['title'] ?? 'Untitled Task',
      subtitle: data['description'] ?? '',
      percent: (data['percent'] ?? TaskConstants.defaultPercent) is int
          ? data['percent'] as int
          : int.tryParse(data['percent'].toString()) ??
                TaskConstants.defaultPercent,
      color: getColorFromQuadrant(data['matrixQuadrant'] as String?),
      startTime: startTime,
      endTime: endTime,
      priority: getPriority(data['priority']),
      difficulty: getDifficulty(data['difficulty']),
      isDone: isDone,
      groupName: (data['groupName'] ?? '') as String,
      reminders: reminders,
      reminderEnabled:
          (data['reminderEnabled'] as bool?) ??
          TaskConstants.defaultReminderEnabled,
      repeatText: data['repeatText'] as String?,
      repeatEndDate: repeatEndMs == null ? null : parseMs(repeatEndMs),
      pinned: (data['pinned'] as bool?) ?? TaskConstants.defaultPinned,
    );
  }

  String _getQuadrantFromColor() {
    return TaskConstants.getQuadrantFromColor(color);
  }
}
