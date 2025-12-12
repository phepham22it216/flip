import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/screens/task_calendar_page.dart';
import 'package:flip/features/tasks/screens/task_edit_page.dart';
import 'package:flip/features/tasks/screens/task_incomplete_page.dart';
import 'package:flip/features/tasks/services/task_service.dart';
import 'package:flip/features/tasks/widgets/task_list/quick_action_button.dart';
import 'package:flip/features/tasks/widgets/task_list/card/task_card_item.dart';
import 'package:flip/features/tasks/widgets/task_list/action_sheet_button.dart';
import 'package:flip/features/tasks/screens/task_detail_page.dart';
import 'package:flip/features/tasks/screens/task_matrix_page.dart';
import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum TaskViewType { list, calendar, matrix }

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskViewType _viewType = TaskViewType.list;
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Nếu chưa đăng nhập, hiển thị thông báo
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Vui lòng đăng nhập để xem công việc')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: StreamBuilder<List<TaskModel>>(
          stream: _taskService.getTasksByUserId(user.uid),
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            final tasks = snapshot.data ?? [];

            return Column(
              children: [
                // Quick Action Button
                QuickActionButton(
                  incompleteTaskCount: tasks.where((t) => !t.isDone).length,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TaskIncompletePage(),
                      ),
                    );
                  },
                ),

                // View Mode Selector
                _buildViewModeSelector(),

                // Content
                Expanded(
                  child: _viewType == TaskViewType.calendar
                      ? TaskCalendarPage(tasks: tasks)
                      : _viewType == TaskViewType.matrix
                      ? TaskMatrixPage(tasks: tasks)
                      : _buildListView(tasks),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// View mode selector (CARD / LỊCH / MATRIX)
  Widget _buildViewModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildViewButton('THẺ', TaskViewType.list),
            _buildDivider(),
            _buildViewButton('LỊCH', TaskViewType.calendar),
            _buildDivider(),
            _buildViewButton('MA TRẬN', TaskViewType.matrix),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 18, color: Colors.grey.shade300);
  }

  Widget _buildViewButton(String label, TaskViewType viewType) {
    final isActive = _viewType == viewType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _viewType = viewType;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.xanh1 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.xanh1.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  /// List view with task cards
  Widget _buildListView(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Chưa có công việc nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút + để thêm công việc mới',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return TaskCardItem(
          task: task,
          onTap: () => _showTaskDetailModal(context, task),
          onToggle: () {
            _taskService.toggleTaskStatus(task.id, !task.isDone);
          },
          onMenu: () => _showTaskActions(context, task),
        );
      },
    );
  }

  void _showTaskDetailModal(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TaskDetailModal(task: task);
      },
    );
  }

  /// Bottom sheet: Edit – Delete – Cancel
  void _showTaskActions(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).padding.bottom;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionSheetButton(
                    text: 'Sửa',
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskEditPage(task: task),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ActionSheetButton(
                    text: 'Xóa',
                    isDestructive: true,
                    onTap: () async {
                      Navigator.pop(ctx);
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: const Text(
                            'Bạn có chắc chắn muốn xóa nhiệm vụ này không?',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        _taskService.deleteTask(task.id);
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(12, 0, 12, bottomPadding + 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ActionSheetButton(
                text: 'Hủy',
                onTap: () => Navigator.pop(ctx),
              ),
            ),
          ],
        );
      },
    );
  }
}
