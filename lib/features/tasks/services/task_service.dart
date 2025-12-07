import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/models/task_constants.dart';

class TaskService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  static const String _tasksPath = 'tasks';

  DatabaseReference get _tasksRef => _db.child(_tasksPath);

  /// Lấy tasks của user theo creatorId
  Stream<List<TaskModel>> getTasksByUserId(String userId) {
    return _tasksRef.orderByChild('creatorId').equalTo(userId).onValue.map((
      event,
    ) {
      final List<TaskModel> tasks = [];
      for (final child in event.snapshot.children) {
        final value = child.value;
        if (value is Map) {
          final data = Map<String, dynamic>.from(value);
          tasks.add(TaskModel.fromMap(data, child.key ?? ''));
        }
      }
      return tasks;
    });
  }

  /// Lấy tasks theo groupId
  Stream<List<TaskModel>> getTasksByGroupId(String groupId) {
    return _tasksRef.orderByChild('groupId').equalTo(groupId).onValue.map((
      event,
    ) {
      final List<TaskModel> tasks = [];
      for (final child in event.snapshot.children) {
        final value = child.value;
        if (value is Map) {
          final data = Map<String, dynamic>.from(value);
          tasks.add(TaskModel.fromMap(data, child.key ?? ''));
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

  /// Xóa task
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.child(taskId).remove();
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

  /// Lấy tasks chưa hoàn thành (status = inProgress)
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
              tasks.add(TaskModel.fromMap(data, child.key ?? ''));
            }
          }
          return tasks;
        });
  }

  /// Lấy tasks theo khoảng thời gian (startTime là millisecondsSinceEpoch)
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
              tasks.add(TaskModel.fromMap(data, child.key ?? ''));
            }
          }
          return tasks;
        });
  }
}
