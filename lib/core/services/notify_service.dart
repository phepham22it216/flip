import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip/features/tasks/services/task_service.dart';
import 'package:flip/features/tasks/models/task_model.dart';

import '../models/notify_model.dart';

class NotifyService {
  final TaskService _taskService = TaskService();

  final List<String> validReminders = [
    "Cả ngày",
    "5 phút trước",
    "10 phút trước",
    "15 phút trước",
    "30 phút trước",
    "1 giờ trước",
    "1 ngày trước",
  ];

  /// Autoload lại để lấy thông báo mới
  static final NotifyService _instance = NotifyService._internal();
  factory NotifyService() => _instance;

  NotifyService._internal() {
    _startAutoRefresh(); // <-- Tự động chạy Timer khi service được tạo
  }

  final StreamController<List<NotifyModel>> _notifyController =
  StreamController.broadcast();

  List<NotifyModel> _cachedNotifications = [];
  Timer? _refreshTimer;

  Stream<List<NotifyModel>> get notificationsStream =>
      _notifyController.stream;

  // KHỞI ĐỘNG TỰ ĐỘNG REFRESH MỖI 1 PHÚT
  void _startAutoRefresh() {
    // Nếu muốn tắt auto-refresh, chỉ cần comment cả hàm này
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await refreshNotifications(); // <- load lại thông báo
    });

    // Load lần đầu
    refreshNotifications();
  }

  Future<void> refreshNotifications() async {
    final newNotifications = await generateNotificationsFromTasks();

    print("Đã tạo ${newNotifications.length} thông báo mới");
    _cachedNotifications = newNotifications;
    _notifyController.add(newNotifications);
  }

  /// Lấy tất cả task của user hiện tại có reminderEnabled = true
  Future<List<TaskModel>> getTasksWithReminders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // Lấy danh sách task 1 lần từ Stream
    final allTasks = await _taskService.getTasksByUserId(user.uid).first;
    print("Task: ${allTasks.length}");
    final now = DateTime.now();

    // Lọc các task có reminderEnabled + còn hiệu lực + có reminder hợp lệ
    final filtered = allTasks.where((task) {
      return task.reminderEnabled == true &&
          task.reminders.isNotEmpty &&
          task.endTime.isAfter(now) &&
          task.reminders.any((r) => validReminders.contains(r));
    }).toList();

    // In ra console task có reminders
    for (var t in filtered) {
      print(
        "Task: ${t.title}, reminderEnabled: ${t.reminderEnabled}, reminders: ${t.reminders}",
      );
    }

    return filtered;
  }

  /// Tạo danh sách thông báo dựa trên task và reminder
  Future<List<NotifyModel>> generateNotificationsFromTasks() async {
    final tasks = await getTasksWithReminders();
    final List<NotifyModel> notifications = [];

    final now = DateTime.now();

    for (var task in tasks) {
      for (var r in task.reminders) {
        // Tính toán thời gian nhắc nhở dựa vào reminder
        DateTime reminderTime = _calculateReminderTime(task.startTime, r);

        // Nếu thời gian nhắc nhở <= hiện tại, tạo thông báo
        if (reminderTime.isBefore(now) || reminderTime.isAtSameMomentAs(now)) {
          notifications.add(
            NotifyModel(
              notificationId: task.id + "_" + r, // ID unique cho task + reminder
              title: "Nhắc nhở công việc",
              content: "Nhớ thực hiện công việc '${task.title}' nhé",
              type: "system",
              taskId: task.id,
              isRead: false,
              createdAt: now,
            ),
          );
        }
      }
    }

    return notifications;
  }

  /// Hàm tính toán thời gian reminder dựa trên startTime và reminder text
  DateTime _calculateReminderTime(DateTime startTime, String reminder) {
    switch (reminder) {
      case "Cả ngày":
        return DateTime(startTime.year, startTime.month, startTime.day, 9, 0);
      case "5 phút trước":
        return startTime.subtract(const Duration(minutes: 5));
      case "10 phút trước":
        return startTime.subtract(const Duration(minutes: 10));
      case "15 phút trước":
        return startTime.subtract(const Duration(minutes: 15));
      case "30 phút trước":
        return startTime.subtract(const Duration(minutes: 30));
      case "1 giờ trước":
        return startTime.subtract(const Duration(hours: 1));
      case "1 ngày trước":
        return startTime.subtract(const Duration(days: 1));
      default:
        return startTime;
    }
  }

  /// Autoload lại để lấy thông báo mới - Phần có liên quan
  void dispose() {
    _refreshTimer?.cancel();
    _notifyController.close();
  }
}
