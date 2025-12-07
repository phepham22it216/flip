import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/services/task_service.dart';
import 'package:flip/features/tasks/widgets/task_list/task_detail_modal.dart';

class TaskMatrixPage extends StatefulWidget {
  final List<TaskModel> tasks;

  const TaskMatrixPage({super.key, required this.tasks});

  @override
  State<TaskMatrixPage> createState() => _TaskMatrixPageState();
}

class _TaskMatrixPageState extends State<TaskMatrixPage> {
  late Map<String, List<TaskModel>> _tasksByQuadrant;
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _tasksByQuadrant = _groupTasksByQuadrant(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant TaskMatrixPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks) {
      _tasksByQuadrant = _groupTasksByQuadrant(widget.tasks);
    }
  }

  Map<String, List<TaskModel>> _groupTasksByQuadrant(List<TaskModel> tasks) {
    final map = <String, List<TaskModel>>{
      'DO_FIRST': [],
      'SCHEDULE': [],
      'DELEGATE': [],
      'ELIMINATE': [],
    };
    for (final task in tasks) {
      final quadrant = _getQuadrantFromColor(task.color);
      map[quadrant]!.add(task);
    }
    return map;
  }

  String _getQuadrantFromColor(Color color) {
    if (color.value == 0xFFFF6B9D) return 'DO_FIRST'; // I
    if (color.value == 0xFF9B59B6) return 'SCHEDULE'; // II
    if (color.value == 0xFF4ECDC4) return 'DELEGATE'; // III
    if (color.value == 0xFFFFB142) return 'ELIMINATE'; // IV
    return 'DO_FIRST';
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Hàng trên: I & II
            Row(
              children: [
                Expanded(
                  child: _buildQuadrantCard(
                    quadrantKey: 'DO_FIRST',
                    emoji: '🔴',
                    title: 'Khẩn cấp và Quan trọng',
                    color: const Color(0xFFFF6B9D),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuadrantCard(
                    quadrantKey: 'SCHEDULE',
                    emoji: '🟡',
                    title: 'Không gấp mà quan trọng',
                    color: const Color(0xFF9B59B6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Hàng dưới: III & IV
            Row(
              children: [
                Expanded(
                  child: _buildQuadrantCard(
                    quadrantKey: 'DELEGATE',
                    emoji: '🔵',
                    title: 'Khẩn cấp nhưng không quan trọng',
                    color: const Color(0xFF4ECDC4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuadrantCard(
                    quadrantKey: 'ELIMINATE',
                    emoji: '🟢',
                    title: 'Không cấp bách và không quan trọng',
                    color: const Color(0xFFFFB142),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuadrantCard({
    required String quadrantKey,
    required String emoji,
    required String title,
    required Color color,
  }) {
    final tasks = _tasksByQuadrant[quadrantKey] ?? [];
    final isEmpty = tasks.isEmpty;

    return DragTarget<({TaskModel task, String sourceQuadrant})>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        _handleTaskDrop(
          task: details.data.task,
          sourceQuadrant: details.data.sourceQuadrant,
          targetQuadrant: quadrantKey,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          constraints: const BoxConstraints(minHeight: 280),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? color.withOpacity(0.6)
                  : Colors.grey.shade200,
              width: candidateData.isNotEmpty ? 2 : 1,
            ),
            boxShadow: candidateData.isNotEmpty
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với emoji + title
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(color: color.withOpacity(0.3)),
                  ),
                ),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Nội dung: hoặc empty state, hoặc list task
              if (isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Không có Nhiệm vụ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    children: List.generate(
                      tasks.length,
                      (index) => _buildDraggableTaskTile(
                        task: tasks[index],
                        sourceQuadrant: quadrantKey,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableTaskTile({
    required TaskModel task,
    required String sourceQuadrant,
  }) {
    final showToday = _isToday(task.startTime);

    return Draggable<({TaskModel task, String sourceQuadrant})>(
      data: (task: task, sourceQuadrant: sourceQuadrant),
      feedback: Material(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: task.color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          width: 250,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isDone ? task.color : Colors.grey.shade300,
                    width: 2,
                  ),
                  color: task.isDone ? task.color : Colors.transparent,
                ),
                child: task.isDone
                    ? const Icon(Icons.check, size: 11, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: task.isDone
                        ? Colors.grey.shade400
                        : AppColors.textPrimary,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const SizedBox(height: 40),
      ),
      child: GestureDetector(
        onTap: () => _showTaskDetailModal(task),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox tròn
              GestureDetector(
                onTap: () {
                  _taskService.toggleTaskStatus(task.id, !task.isDone);
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isDone ? task.color : Colors.grey.shade300,
                      width: 2,
                    ),
                    color: task.isDone ? task.color : Colors.transparent,
                  ),
                  child: task.isDone
                      ? const Icon(Icons.check, size: 11, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              // Tiêu đề + "Hôm nay"
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: task.isDone
                            ? Colors.grey.shade400
                            : AppColors.textPrimary,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (showToday)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Hôm nay',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.xanh1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTaskDrop({
    required TaskModel task,
    required String sourceQuadrant,
    required String targetQuadrant,
  }) {
    if (sourceQuadrant == targetQuadrant) return;

    // Get color for target quadrant
    Color newColor = _getColorForQuadrant(targetQuadrant);

    // Update UI locally
    setState(() {
      _tasksByQuadrant[sourceQuadrant]?.removeWhere((t) => t.id == task.id);
      _tasksByQuadrant[targetQuadrant]?.add(task.copyWith(color: newColor));
    });

    // Update task color in database
    _taskService.updateTask(task.id, task.copyWith(color: newColor));

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${task.title} đã được chuyển',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getColorForQuadrant(String quadrant) {
    switch (quadrant) {
      case 'DO_FIRST':
        return const Color(0xFFFF6B9D);
      case 'SCHEDULE':
        return const Color(0xFF9B59B6);
      case 'DELEGATE':
        return const Color(0xFF4ECDC4);
      case 'ELIMINATE':
        return const Color(0xFFFFB142);
      default:
        return const Color(0xFFFF6B9D);
    }
  }

  void _showTaskDetailModal(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TaskDetailModal(task: task);
      },
    );
  }
}
