import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/models/task_constants.dart';

class TaskService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  static const String _tasksPath = 'tasks';

  DatabaseReference get _tasksRef => _db.child(_tasksPath);

  /// Tạo reference cho task của user cụ thể (dùng cho user-specific tasks)
  DatabaseReference getTaskRef(String userId) {
    return FirebaseDatabase.instance.ref("users/$userId/tasks");
  }

  /// Lấy tasks của user theo creatorId (chỉ activity = true)
  Stream<List<TaskModel>> getTasksByUserId(String userId) {
    return _tasksRef.orderByChild('creatorId').equalTo(userId).onValue.map((
      event,
    ) {
      final List<TaskModel> tasks = [];
      for (final child in event.snapshot.children) {
        final value = child.value;
        if (value is Map) {
          final data = Map<String, dynamic>.from(value);
          final activity = data['activity'] as bool? ?? true;
          if (activity) {
            tasks.add(TaskModel.fromMap(data, child.key ?? ''));
          }
        }
      }
      return tasks;
    });
  }

  /// Lấy tasks theo groupId (chỉ activity = true)
  Stream<List<TaskModel>> getTasksByGroupId(String groupId) {
    return _tasksRef.orderByChild('groupId').equalTo(groupId).onValue.map((
      event,
    ) {
      final List<TaskModel> tasks = [];
      for (final child in event.snapshot.children) {
        final value = child.value;
        if (value is Map) {
          final data = Map<String, dynamic>.from(value);
          final activity = data['activity'] as bool? ?? true;
          if (activity) {
            tasks.add(TaskModel.fromMap(data, child.key ?? ''));
          }
        }
      }
      return tasks;
    });
  }

  /// Thêm task mới
  Future<void> addTask(TaskModel task, {String? groupId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final newRef = _tasksRef.push();
    final data = task.toMap();

    data['creatorId'] = user.uid;
    // Khi tạo mới, luôn set matrixQuadrant là ELIMINATE (không khẩn cấp, không quan trọng)
    data['matrixQuadrant'] = TaskConstants.defaultQuadrant;
    if (groupId != null) {
      data['groupId'] = groupId;
      data['type'] = TaskConstants.typeGroup;
    }
    data['createdAt'] = DateTime.now();
    data['updatedAt'] = DateTime.now();

    await newRef.set(data);
  }

  /// Thêm task mới cho user cụ thể
  Future<void> createTask(String userId, TaskModel task) async {
    await getTaskRef(userId).child(task.id).set(task.toMap());
  }

  /// Cập nhật quadrant khi kéo task qua matrix khác
  Future<void> updateTaskQuadrant(String taskId, String quadrant) async {
    final colorValue = TaskConstants.getColorValue(quadrant);
    await _tasksRef.child(taskId).update({
      'matrixQuadrant': quadrant,
      'color': colorValue,
      'updatedAt': ServerValue.timestamp,
    });
  }

  /// Cập nhật task
  Future<void> updateTask(String taskId, TaskModel task) async {
    final data = task.toMap();
    data.remove('createdAt');
    data['updatedAt'] = ServerValue.timestamp;

    await _tasksRef.child(taskId).update(data);
  }

  /// Cập nhật task cho user cụ thể
  Future<void> updateTaskForUser(
    String userId,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    data["updatedAt"] = ServerValue.timestamp;
    await getTaskRef(userId).child(taskId).update(data);
  }

  /// Xóa task (đánh dấu activity = false)
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.child(taskId).update({
      "activity": false,
      "updatedAt": ServerValue.timestamp,
    });
  }

  /// Xóa task cho user cụ thể (đánh dấu activity = false)
  Future<void> deleteTaskForUser(String userId, String taskId) async {
    await _tasksRef.child(taskId).update({
      "activity": false,
      "updatedAt": ServerValue.timestamp,
    });
  }

  /// Hoàn thành task cho user cụ thể
  Future<void> completeTask(String userId, String taskId) async {
    await _tasksRef.child(taskId).update({
      "isDone": true,
      "status": TaskConstants.statusCompleted,
      "updatedAt": ServerValue.timestamp,
    });
  }

  /// Lấy task theo ID cho user cụ thể
  Future<TaskModel?> getTaskForUser(String userId, String taskId) async {
    final snapshot = await getTaskRef(userId).child(taskId).get();
    if (!snapshot.exists) return null;

    return TaskModel.fromMap(
      Map<String, dynamic>.from(snapshot.value as Map),
      taskId,
    );
  }

  /// Lấy tất cả task của user cụ thể
  Future<List<TaskModel>> getAllTasksForUser(String userId) async {
    final snapshot = await getTaskRef(userId).get();
    if (!snapshot.exists) return [];

    final List<TaskModel> tasks = [];
    for (var child in snapshot.children) {
      tasks.add(
        TaskModel.fromMap(
          Map<String, dynamic>.from(child.value as Map),
          child.key ?? '',
        ),
      );
    }
    return tasks;
  }

  /// Stream các task của user cụ thể
  Stream<List<TaskModel>> tasksStreamForUser(String userId) {
    return getTaskRef(userId).onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final List<TaskModel> tasks = [];
      for (var child in event.snapshot.children) {
        tasks.add(
          TaskModel.fromMap(
            Map<String, dynamic>.from(child.value as Map),
            child.key ?? '',
          ),
        );
      }
      return tasks;
    });
  }

  /// Đánh dấu hoàn thành / chưa hoàn thành
  Future<void> toggleTaskStatus(String taskId, bool isDone) async {
    await _tasksRef.child(taskId).update({
      'status': isDone
          ? TaskConstants.statusCompleted
          : TaskConstants.statusInProgress,
      'updatedAt': ServerValue.timestamp,
    });
  }

  /// Lấy tasks chưa hoàn thành (status = inProgress, activity = true)
  Stream<List<TaskModel>> getIncompleteTasks() {
    return _tasksRef
        .orderByChild('status')
        .equalTo(TaskConstants.statusInProgress)
        .onValue
        .map((event) {
          final List<TaskModel> tasks = [];
          for (final child in event.snapshot.children) {
            final value = child.value;
            if (value is Map) {
              final data = Map<String, dynamic>.from(value);
              final activity = data['activity'] as bool? ?? true;
              if (activity) {
                tasks.add(TaskModel.fromMap(data, child.key ?? ''));
              }
            }
          }
          return tasks;
        });
  }

  /// Lấy tasks theo khoảng thời gian (startTime là millisecondsSinceEpoch, activity = true)
  Stream<List<TaskModel>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;

    return _tasksRef
        .orderByChild('startTime')
        .startAt(startMs)
        .endAt(endMs)
        .onValue
        .map((event) {
          final List<TaskModel> tasks = [];
          for (final child in event.snapshot.children) {
            final value = child.value;
            if (value is Map) {
              final data = Map<String, dynamic>.from(value);
              final activity = data['activity'] as bool? ?? true;
              if (activity) {
                tasks.add(TaskModel.fromMap(data, child.key ?? ''));
              }
            }
          }
          return tasks;
        });
  }
}
