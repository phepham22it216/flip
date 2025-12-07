import 'package:flutter/material.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/models/task_constants.dart';
import 'package:flip/features/tasks/services/task_service.dart';

import 'package:flip/features/tasks/widgets/task_list/matrix/matrix_layout.dart';
import 'package:flip/features/tasks/widgets/task_list/matrix/task_utils.dart';
import 'package:flip/features/tasks/widgets/task_list/task_detail_modal.dart';

class TaskMatrixPage extends StatefulWidget {
  final List<TaskModel> tasks;

  const TaskMatrixPage({Key? key, required this.tasks}) : super(key: key);

  @override
  State<TaskMatrixPage> createState() => _TaskMatrixPageState();
}

class _TaskMatrixPageState extends State<TaskMatrixPage> {
  late Map<String, List<TaskModel>> _tasksByQuadrant;
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _tasksByQuadrant = TaskUtils.groupTasksByQuadrant(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant TaskMatrixPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks) {
      setState(() {
        _tasksByQuadrant = TaskUtils.groupTasksByQuadrant(widget.tasks);
      });
    }
  }

  void _handleTaskDrop(
    TaskModel task,
    String sourceQuadrant,
    String targetQuadrant,
  ) {
    if (sourceQuadrant == targetQuadrant) return;

    Color newColor = TaskConstants.getColorFromQuadrant(targetQuadrant);

    setState(() {
      _tasksByQuadrant[sourceQuadrant]?.removeWhere((t) => t.id == task.id);
      _tasksByQuadrant[targetQuadrant]?.add(
        task.copyWith(color: newColor, matrixQuadrant: targetQuadrant),
      );
    });

    _taskService.updateTaskQuadrant(task.id, targetQuadrant);

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: MatrixLayout(
          tasksByQuadrant: _tasksByQuadrant,
          onTaskDrop: _handleTaskDrop,
          onTaskTap: _showTaskDetailModal,
        ),
      ),
    );
  }
}
