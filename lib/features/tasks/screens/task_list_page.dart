import 'package:flip/features/tasks/models/task_item.dart';
import 'package:flip/features/tasks/screens/task_calendar_page.dart';
import 'package:flip/features/tasks/screens/task_edit_page.dart';
import 'package:flip/features/tasks/screens/task_incomplete_page.dart';
import 'package:flip/features/tasks/widgets/task_list/task_detail_modal.dart';
import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

enum TaskViewType { list, calendar }

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskViewType _viewType = TaskViewType.list;

  final List<TaskItem> _tasks = [
    TaskItem(
      id: '1',
      title: "Reading",
      subtitle: "Đọc sách tài liệu liên quan đến Flutter và Dart",
      percent: 0,
      durationText: "00:00:00",
      color: AppColors.hong,
      startTime: DateTime(2024, 12, 23, 8, 0),
      endTime: DateTime(2024, 12, 23, 10, 0),
      priority: 2,
      difficulty: 1,
      isDone: false,
      groupName: 'Học tập',
      reminders: ['5 phút trước'],
      reminderEnabled: true,
      repeatText: 'Mỗi 4 Thứ Bảy',
      repeatEndDate: DateTime(2025, 3, 31),
      pinned: true,
    ),
    TaskItem(
      id: '2',
      title: "Học Đa Nền Tảng",
      subtitle:
          "Hoàn thành các bài tập thực hành trong lớp học. Luyện tập các khái niệm lập trình đa nền tảng",
      percent: 50,
      durationText: "02:30:00",
      color: AppColors.tim1,
      startTime: DateTime.now()
          .add(const Duration(days: 1))
          .copyWith(hour: 9, minute: 0),
      endTime: DateTime.now()
          .add(const Duration(days: 1))
          .copyWith(hour: 11, minute: 30),
      priority: 3,
      difficulty: 2,
      isDone: false,
      groupName: 'Lớp học',
    ),
    TaskItem(
      id: '3',
      title: "Học Java",
      subtitle: "Ôn tập các kiến thức về Java OOP và design patterns",
      percent: 75,
      durationText: "03:45:00",
      color: AppColors.xanh2,
      startTime: DateTime.now()
          .add(const Duration(days: 2))
          .copyWith(hour: 13, minute: 0),
      endTime: DateTime.now()
          .add(const Duration(days: 2))
          .copyWith(hour: 16, minute: 45),
      priority: 2,
      difficulty: 2,
      isDone: false,
      groupName: 'Lập trình',
    ),
    TaskItem(
      id: '4',
      title: "Làm bài tập Flutter",
      subtitle: "Hoàn thành project todo app với Firebase",
      percent: 30,
      durationText: "01:15:00",
      color: AppColors.cam,
      startTime: DateTime.now()
          .add(const Duration(days: 5))
          .copyWith(hour: 14, minute: 0),
      endTime: DateTime.now()
          .add(const Duration(days: 5))
          .copyWith(hour: 15, minute: 15),
      priority: 3,
      difficulty: 3,
      isDone: false,
      groupName: 'Project',
    ),
    TaskItem(
      id: '5',
      title: "Review Code",
      subtitle: "Kiểm tra và đánh giá code của các bạn cùng team",
      percent: 60,
      durationText: "01:30:00",
      color: AppColors.xanhLa1,
      startTime: DateTime.now().copyWith(hour: 10, minute: 0),
      endTime: DateTime.now().copyWith(hour: 11, minute: 30),
      priority: 2,
      difficulty: 1,
      isDone: true,
      groupName: 'Team',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Quick Action Button - Công việc chưa hoàn thành
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskIncompletePage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.cam, Color(0xFFFF6B00)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cam.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.pending_actions,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Công việc chưa hoàn thành',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_tasks.where((t) => !t.isDone).length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Segmented control: CARD / LỊCH
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewButton('CARD', TaskViewType.list),
                    _buildDivider(),
                    _buildViewButton('LỊCH', TaskViewType.calendar),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _viewType == TaskViewType.calendar
                  ? TaskCalendarPage(tasks: _tasks)
                  : _buildListView(),
            ),
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

  /// LIST VIEW – mỗi item có nút tick + 3 chấm
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];

        return GestureDetector(
          onTap: () {
            _showTaskDetailModal(context, task);
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: task.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Nút tick
                  IconButton(
                    iconSize: 28,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      task.isDone
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _tasks[index] = task.copyWith(
                          isDone: !task.isDone,
                        ); // toggle
                      });
                    },
                  ),

                  const SizedBox(width: 12),

                  // Title + repeat text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.groupName, // ví dụ: Everyday / Fri / Nhóm
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // % + time + menu 3 chấm
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${task.percent}%',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.durationText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // 3 chấm
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      _showTaskActions(context, index, task);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTaskDetailModal(BuildContext context, TaskItem task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TaskDetailModal(task: task);
      },
    );
  }

  /// Bottom sheet: Xóa – Sửa – Hủy
  void _showTaskActions(BuildContext context, int index, TaskItem task) {
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
                  _ActionSheetButton(
                    text: 'Sửa',
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskEditPage(task: _tasks[index]),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _ActionSheetButton(
                    text: 'Xóa',
                    isDestructive: true,
                    onTap: () {
                      setState(() {
                        _tasks.removeAt(index);
                      });
                      Navigator.pop(ctx);
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
              child: _ActionSheetButton(
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

/// Nút trong action sheet
class _ActionSheetButton extends StatelessWidget {
  final String text;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionSheetButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.blue,
          ),
        ),
      ),
    );
  }
}
