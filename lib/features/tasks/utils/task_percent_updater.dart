import 'dart:async';
import 'package:flip/features/tasks/models/task_model.dart';

/// Utility để cập nhập percent tự động theo thời gian thực
class TaskPercentUpdater {
  static final TaskPercentUpdater _instance = TaskPercentUpdater._internal();

  factory TaskPercentUpdater() {
    return _instance;
  }

  TaskPercentUpdater._internal();

  Timer? _timer;
  final Map<String, Function(int)> _listeners = {};

  /// Bắt đầu cập nhập percent theo thời gian thực cho một task
  void startListening(
    String taskId,
    TaskModel task,
    Function(int) onPercentChanged,
  ) {
    _listeners[taskId] = onPercentChanged;

    // Nếu chưa có timer, tạo timer cập nhập mỗi 1 giây
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _updateAllListeners(),
      );
    }
    // Gọi callback lần đầu
    onPercentChanged(task.getAutoPercent());
  }

  /// Dừng lắng nghe cho một task
  void stopListening(String taskId) {
    _listeners.remove(taskId);

    // Nếu không còn listeners, dừng timer
    if (_listeners.isEmpty && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// Dừng tất cả listeners
  void stopAllListeners() {
    _listeners.clear();
    _timer?.cancel();
    _timer = null;
  }

  void _updateAllListeners() {
    // Khi timer tick, các widget đang lắng nghe sẽ rebuild
    // và gọi getAutoPercent() để lấy giá trị mới
  }
}
