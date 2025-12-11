import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flip/features/tasks/services/task_service.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart';
import '../models/notify_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotifyService {
  final TaskService _taskService = TaskService();

  final DatabaseReference _notifRef = FirebaseDatabase.instance.ref().child(
    "notifications",
  );

  // Thêm vào hàm này
  Future<void> saveNotificationToDB(NotifyModel notif, String userId) async {
    final ref = _notifRef.child(notif.notificationId);
    await ref.set({
      ...notif.toMap(),
      "userId": userId, // cần để phân biệt user
      "updatedAt": DateTime.now().toIso8601String(),
    });
  }

  final List<String> validReminders = [
    "Cả ngày",
    "5 phút trước",
    "10 phút trước",
    "15 phút trước",
    "30 phút trước",
    "1 giờ trước",
    "1 ngày trước",
  ];

  /// Singleton — để tránh tạo nhiều instance gây chạy Timer nhiều lần
  static final NotifyService _instance = NotifyService._internal();
  factory NotifyService() => _instance;

  bool _autoRefreshStarted = false;

  NotifyService._internal() {
    if (kIsWeb && !_autoRefreshStarted) {
      _autoRefreshStarted = true;
      _startAutoRefresh(); // ⚠️ COMMENT DÒNG NÀY hoặc comment toàn bộ function _startAutoRefresh() ĐỂ TẮT AUTO REFRESH
    }
    else if (!kIsWeb) {
      _scheduleMobileNotifications();
      _startAutoRefresh();
    }
  }

  final StreamController<List<NotifyModel>> _notifyController =
      StreamController.broadcast();

  List<NotifyModel> _cachedNotifications = [];
  Timer? _refreshTimer;

  Stream<List<NotifyModel>> get notificationsStream => _notifyController.stream;

  // ---------------------------------------------------------------------------
  // AUTO REFRESH MỖI 1 PHÚT
  // ---------------------------------------------------------------------------
  void _startAutoRefresh() {
    // ❗ COMMENT CẢ KHỐI NÀY = TẮT TỰ ĐỘNG TẢI THÔNG BÁO Duration(seconds: 30) or Duration(minutes: 1)
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await refreshNotifications();
    });

    refreshNotifications(); // chạy lần đầu
  }

  Future<void> refreshNotifications() async {
    final newNotifications = await generateNotificationsFromTasks();

    print("▶ NotifyService: Tạo ${newNotifications.length} thông báo");

    // Fixed here: merge notifications cũ với notifications mới
    final merged = [..._cachedNotifications];
    for (var n in newNotifications) {
      if (!merged.any((e) => e.notificationId == n.notificationId)) {
        merged.add(n);
      }
    }

    _cachedNotifications =
        merged; // Fixed here: cập nhật cachedNotifications bằng merged
    _notifyController.add(
      merged,
    ); // Fixed here: phát Stream với tất cả notifications
  }

  // ---------------------------------------------------------------------------
  // LẤY TASK CÓ REMINDER
  // ---------------------------------------------------------------------------
  Future<List<TaskModel>> getTasksWithReminders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final allTasks = await _taskService.getTasksByUserId(user.uid).first;
    final now = DateTime.now();
    print("📌 Tổng task: ${allTasks.length}");

    // ---------------------------
    // 1️⃣ Lọc task theo reminder
    // ---------------------------
    final filtered = allTasks.where((task) {
      return task.status == "inProgress" &&
          task.reminderEnabled == true &&
          task.reminders.isNotEmpty &&
          task.endTime.isAfter(now) &&
          task.reminders.any((r) => validReminders.contains(r));
    }).toList();

    print("📌 Task đủ điều kiện reminder: ${filtered.length}");
    if (filtered.isEmpty) return [];

    // ---------------------------
    // 2️⃣ Lấy notify đã đọc hôm nay
    // ---------------------------
    final notifSnapshot = await _notifRef
        .orderByChild("userId")
        .equalTo(user.uid)
        .get();

    print("📥 Snapshot notify: ${notifSnapshot.value.runtimeType}");

    List<String> readTaskIdsToday = [];

    if (notifSnapshot.value != null && notifSnapshot.value is Map) {
      final Map data = notifSnapshot.value as Map;
      print("📥 Tổng notify: ${data.length}");

      for (var entry in data.entries) {
        final raw = entry.value;

        // Sai kiểu -> bỏ qua
        if (raw is! Map) continue;

        final value = Map<String, dynamic>.from(raw);

        final bool isRead = value["isRead"] == true;
        final String? taskId = value["taskId"];
        final String? createdAtStr = value["createdAt"];

        print("🔹 Notify check:");
        print("   ➤ isRead = $isRead");
        print("   ➤ taskId = $taskId");
        print("   ➤ createdAt = $createdAtStr");

        if (!isRead || taskId == null || createdAtStr == null) continue;

        final DateTime createdAt =
            DateTime.tryParse(createdAtStr) ?? now;

        final bool isToday =
            createdAt.year == now.year &&
                createdAt.month == now.month &&
                createdAt.day == now.day;

        if (isToday) {
          print("✅ Notify hôm nay: $taskId");
          readTaskIdsToday.add(taskId);
        }
      }
    }

    print("📌 Tổng taskId cần loại bỏ: ${readTaskIdsToday.length}");

    // ---------------------------
    // 3️⃣ Loại task đã bị notify hôm nay + đã đọc
    // ---------------------------
    final result =
    filtered.where((t) => !readTaskIdsToday.contains(t.id)).toList();

    print("📌 Sau khi lọc notify: ${result.length} task còn lại");

    return result;
  }


  // ---------------------------------------------------------------------------
  // TẠO THÔNG BÁO TỪ TASK + REMINDER
  // ---------------------------------------------------------------------------
  Future<List<NotifyModel>> generateNotificationsFromTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final tasks = await getTasksWithReminders();
    print("Task: ${tasks.length}");

    final now = DateTime.now();

    final List<NotifyModel> notifications = [];

    for (var task in tasks) {
      for (var r in task.reminders) {
        DateTime reminderTime = _calculateReminderTime(task.startTime, r);

        // Nếu reminder chưa tới → không tạo thông báo
        if (reminderTime.isAfter(now)) {
          print("⏳ Reminder chưa tới: $reminderTime");
          continue;
        }

        final id = "${task.id}_$r";
        if (_cachedNotifications.any((n) => n.notificationId == id)) continue;

        final shortTitle = task.title.length > 8
            ? "${task.title.substring(0, 8)}..."
            : task.title;

        final notif = NotifyModel(
          notificationId: id,
          title: "Nhắc nhở",
          content: "Bạn có việc '$shortTitle' sắp tới!",
          type: "System",
          taskId: task.id,
          isRead: false,
          createdAt: now,
        );

        // 1️⃣ Lưu vào Realtime Database
        await saveNotificationToDB(notif, user.uid);

        notifications.add(notif);
      }
    }

    return notifications;
  }

  // ---------------------------------------------------------------------------
  // TÍNH GIỜ REMINDER
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // HỦY SERVICE (KHÔNG BẮT BUỘC)
  // ---------------------------------------------------------------------------
  void dispose() {
    _refreshTimer?.cancel();
    _notifyController.close();
  }

  // MOBILE
  Future<void> _scheduleMobileNotifications() async {
    final tasks = await getTasksWithReminders();

    for (var task in tasks) {
      for (var r in task.reminders) {
        DateTime reminderTime = _calculateReminderTime(task.startTime, r);

        // reminder chưa tới → schedule
        if (reminderTime.isAfter(DateTime.now())) {
          _scheduleLocalNotification(
            id: task.id.hashCode ^ r.hashCode,
            title: "Nhắc nhở công việc",
            body: "Nhớ thực hiện công việc '${task.title}' nhé",
            scheduledTime: reminderTime,
          );
        }
      }
    }
  }

  Future<void> _scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final android = AndroidNotificationDetails(
      'task_channel',
      'Task Reminders',
      channelDescription: 'Nhắc nhở công việc',
      importance: Importance.max,
      priority: Priority.high,
    );

    final ios = DarwinNotificationDetails();

    final platform = NotificationDetails(android: android, iOS: ios);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platform,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
      payload: null,
    );
  }

  Future<void> refreshMobileSchedule() async {
    if (kIsWeb) return;

    // Xoá toàn bộ schedule cũ
    await flutterLocalNotificationsPlugin.cancelAll();

    // Tạo lịch mới
    await _scheduleMobileNotifications();
  }

  // ⭐ HÀM MỚI — hiện thông báo ngay lập tức trên mobile
  Future<void> showMobileInstantNotification(NotifyModel notif) async {
    if (kIsWeb) return;

    final android = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      channelDescription: 'Thông báo ngay lập tức khi có dữ liệu mới',
      importance: Importance.max,
      priority: Priority.high,
    );

    final ios = DarwinNotificationDetails();

    final platform = NotificationDetails(android: android, iOS: ios);

    await flutterLocalNotificationsPlugin.show(
      notif.notificationId.hashCode,
      notif.title,
      notif.content,
      platform,
    );
  }

  Future<void> initMobile() async {
    if (!kIsWeb) {
      await refreshMobileSchedule();
    }
  }

  //CƠ SỞ DỮ LIỆU
  // Load tất cả thông báo của user từ Realtime DB
  Future<void> loadNotificationsFromDB() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ loadNotificationsFromDB: user == null (chưa đăng nhập?)");
      return;
    }

    print("🔑 loadNotificationsFromDB: uid = ${user.uid}, email = ${user.email}");

    try {
      // ⭐ ĐÃ SỬA — dùng listener thay vì chỉ load 1 lần
      final query = _notifRef.orderByChild("userId").equalTo(user.uid);

      // ⭐ ĐÃ SỬA — thêm listener realtime
      query.onValue.listen((DatabaseEvent event) {
        final snapshot = event.snapshot;

        if (snapshot.value == null) {
          print("📥 Không có thông báo nào (realtime)");
          _cachedNotifications = [];
          _notifyController.add([]);
          return;
        }

        print("📥 snapshot.value type = ${snapshot.value.runtimeType}");

        final List<NotifyModel> list = [];

        // ⭐ Giữ logic parse cũ
        if (snapshot.value is Map) {
          final Map<dynamic, dynamic> data = snapshot.value as Map;
          for (final entry in data.entries) {
            try {
              final value = entry.value;
              print(
                "  ➜ key = ${entry.key}, value type = ${value.runtimeType}",
              );

              if (value is Map) {
                list.add(
                  NotifyModel.fromMap(
                    Map<String, dynamic>.from(value as Map),
                  ),
                );
              }
            } catch (e) {
              print("  ❌ Lỗi parse notification ${entry.key}: $e");
            }
          }
        }

        print("✅ parsed notifications (realtime) = ${list.length}");

        // ⭐ XÁC ĐỊNH THÔNG BÁO MỚI
        for (var notif in list) {
          final existed = _cachedNotifications.any(
                (old) => old.notificationId == notif.notificationId,
          );

          if (!existed) {
            print("📢 PHÁT HIỆN THÔNG BÁO MỚI: ${notif.notificationId}");

            // ⭐ GỌI POPUP MOBILE (Only Mobile)
            showMobileInstantNotification(notif);
          }
        }

        // ⭐ CẬP NHẬT CACHE SAU KHI XỬ LÝ
        _cachedNotifications = list;
        _notifyController.add(list);

      });

      print("🟢 Real-time listener được kích hoạt!");
    } catch (e) {
      print("❌ Exception: $e");
    }
  }

  // Cập nhật tất cả thông báo là đã đọc
  Future<void> markAllAsRead(List<NotifyModel> notifications) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    for (var n in notifications) {
      n.isRead = true;
      await _notifRef.child(n.notificationId).update({
        "isRead": true,
        "updatedAt": DateTime.now().toIso8601String(),
      });
    }
  }
}

String formatTime(DateTime date) {
  final now = DateTime.now();

  final isToday = date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;

  if (isToday) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  } else {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
  }
}
