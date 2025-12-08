import 'package:flutter/material.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/widgets/task_list/matrix/task_tile.dart';

typedef OnTaskTap = Function(TaskModel task);

class QuadrantCard extends StatelessWidget {
  final String quadrantKey;
  final String emoji;
  final String title;
  final Color color;
  final List<TaskModel> tasks;
  final OnTaskTap onTaskTap;
  final Function(TaskModel, String, String) onTaskDrop;

  const QuadrantCard({
    super.key,
    required this.quadrantKey,
    required this.emoji,
    required this.title,
    required this.color,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskDrop,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = tasks.isEmpty;

    return DragTarget<({TaskModel task, String sourceQuadrant})>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        onTaskDrop(details.data.task, details.data.sourceQuadrant, quadrantKey);
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
              _buildHeader(),
              if (isEmpty) _buildEmptyState() else _buildTaskList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: color.withOpacity(0.3))),
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
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Không có Nhiệm vụ',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: List.generate(
          tasks.length,
          (index) => TaskTile(
            task: tasks[index],
            sourceQuadrant: quadrantKey,
            onTaskTap: onTaskTap,
            onTaskDrop: onTaskDrop,
          ),
        ),
      ),
    );
  }
}
