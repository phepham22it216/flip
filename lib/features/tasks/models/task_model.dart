import 'package:flutter/material.dart';
import 'package:flip/features/tasks/models/task_constants.dart';
import 'package:flip/theme/app_colors.dart';

class TaskModel {
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final String colorName;
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
  final String? matrixQuadrant; // DO_FIRST, SCHEDULE, DELEGATE, ELIMINATE
  final bool activity; // true: active, false: deleted

  // NEW: map of memberUid -> true (or any truthy value)
  final Map<String, dynamic> membersDone;

  TaskModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.color,
    required this.colorName,
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
    this.matrixQuadrant,
    this.activity = true,
    this.membersDone = const {},
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    Color? color,
    String? colorName,
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
    String? matrixQuadrant,
    bool? activity,
    Map<String, dynamic>? membersDone,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      color: color ?? this.color,
      colorName: colorName ?? this.colorName,
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
      matrixQuadrant: matrixQuadrant ?? this.matrixQuadrant,
      activity: activity ?? this.activity,
      membersDone: membersDone ?? this.membersDone,
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
      'colorName': colorName,
      'matrixQuadrant': _getQuadrantFromColor(),
      'priority': priority,
      'difficulty': difficulty,
      'type': _isGroupMode
          ? TaskConstants.typeGroup
          : TaskConstants.typePersonal,
      'groupName': groupName,
      'reminders': reminders,
      'reminderEnabled': reminderEnabled,
      'repeatText': repeatText,
      'repeatEndDate': repeatEndDate?.millisecondsSinceEpoch,
      'pinned': pinned,
      'activity': activity,
      // NEW membersDone map (empty map if none)
      'membersDone': membersDone,
      // createdAt/updatedAt as ISO string to avoid storing DateTime object
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
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

  /// Tính phần trăm tự động dựa trên thời gian đã trôi qua
  /// Formula: percent = (currentTime - startTime) / (endTime - startTime) * 100
  int getAutoPercent() {
    if (isDone) return 100;

    final now = DateTime.now();

    // Nếu chưa bắt đầu, percent = 0
    if (now.isBefore(startTime)) {
      return 0;
    }

    // Nếu đã kết thúc, percent = 100
    if (now.isAfter(endTime)) {
      return 100;
    }

    // Tính phần trăm dựa trên thời gian đã trôi qua
    final totalDuration = endTime.difference(startTime).inSeconds;
    final elapsedDuration = now.difference(startTime).inSeconds;

    if (totalDuration <= 0) return 0;

    final calculatedPercent = (elapsedDuration / totalDuration * 100).toInt();
    return calculatedPercent.clamp(0, 100);
  }

  /// Tạo TaskModel từ data Realtime Database
  factory TaskModel.fromMap(Map<String, dynamic> data, String docId) {
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
      if (value is String) {
        // Try parsing ISO string first
        try {
          return DateTime.parse(value);
        } catch (_) {
          // fallback: try parse as int string
          final intVal = int.tryParse(value);
          if (intVal != null)
            return DateTime.fromMillisecondsSinceEpoch(intVal);
        }
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

    // membersDone: safe parse to Map<String, dynamic>
    Map<String, dynamic> parseMembersDone(dynamic raw) {
      if (raw == null) return {};
      if (raw is Map) {
        try {
          return Map<String, dynamic>.from(
            raw.map((k, v) => MapEntry(k.toString(), v)),
          );
        } catch (_) {
          // fallback: convert entries manually
          final out = <String, dynamic>{};
          raw.forEach((k, v) => out[k.toString()] = v);
          return out;
        }
      }
      return {};
    }

    final membersDone = parseMembersDone(data['membersDone']);

    // Get colorName from data, fallback to matrixQuadrant
    final colorNameStr = (data['colorName'] as String?) ?? 'xanh1';
    final taskColor = _getColorFromName(colorNameStr);

    return TaskModel(
      id: docId,
      title: data['title'] ?? 'Untitled Task',
      subtitle: data['description'] ?? '',
      color: taskColor,
      colorName: colorNameStr,
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
      matrixQuadrant:
          (data['matrixQuadrant'] as String?) ?? TaskConstants.defaultQuadrant,
      activity: (data['activity'] as bool?) ?? true,
      membersDone: membersDone,
    );
  }

  static Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'hong':
        return AppColors.hong;
      case 'da':
        return AppColors.da;
      case 'xanh2':
        return AppColors.xanh2;
      case 'xanh1':
        return AppColors.xanh1;
      case 'xanh3':
        return AppColors.xanh3;
      case 'doSoft':
        return AppColors.doSoft;
      case 'xanhLa1':
        return AppColors.xanhLa1;
      case 'xanhLa2':
        return AppColors.xanhLa2;
      case 'xanhLa3':
        return AppColors.xanhLa3;
      case 'tim1':
        return AppColors.tim1;
      case 'tim2':
        return AppColors.tim2;
      case 'cam':
        return AppColors.cam;
      case 'vang':
        return AppColors.vang;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.xanh1; // Default color
    }
  }

  String _getQuadrantFromColor() {
    return TaskConstants.getQuadrantFromColor(color);
  }
}
