import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/services/task_service.dart';

typedef OnTaskTap = Function(TaskModel task);

class TaskTile extends StatefulWidget {
  final TaskModel task;
  final String sourceQuadrant;
  final OnTaskTap onTaskTap;
  final Function(TaskModel, String, String) onTaskDrop;

  const TaskTile({
    super.key,
    required this.task,
    required this.sourceQuadrant,
    required this.onTaskTap,
    required this.onTaskDrop,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  final TaskService _taskService = TaskService();

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final showToday = _isToday(widget.task.startTime);

    return Draggable<({TaskModel task, String sourceQuadrant})>(
      data: (task: widget.task, sourceQuadrant: widget.sourceQuadrant),
      feedback: Material(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.task.color.withOpacity(0.4),
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
                    color: widget.task.isDone
                        ? widget.task.color
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  color: widget.task.isDone
                      ? widget.task.color
                      : Colors.transparent,
                ),
                child: widget.task.isDone
                    ? const Icon(Icons.check, size: 11, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.task.isDone
                        ? Colors.grey.shade400
                        : AppColors.textPrimary,
                    decoration: widget.task.isDone
                        ? TextDecoration.lineThrough
                        : null,
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
        onTap: () => widget.onTaskTap(widget.task),
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
                  _taskService.toggleTaskStatus(
                    widget.task.id,
                    !widget.task.isDone,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.task.isDone
                          ? widget.task.color
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    color: widget.task.isDone
                        ? widget.task.color
                        : Colors.transparent,
                  ),
                  child: widget.task.isDone
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
                      widget.task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.task.isDone
                            ? Colors.grey.shade400
                            : AppColors.textPrimary,
                        decoration: widget.task.isDone
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
}
