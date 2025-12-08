import 'package:flutter/material.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/models/task_constants.dart';
import 'package:flip/features/tasks/widgets/task_list/matrix/quadrant_card.dart';

typedef OnTaskTap = Function(TaskModel task);

class MatrixLayout extends StatelessWidget {
  final Map<String, List<TaskModel>> tasksByQuadrant;
  final OnTaskTap onTaskTap;
  final Function(TaskModel, String, String) onTaskDrop;

  const MatrixLayout({
    super.key,
    required this.tasksByQuadrant,
    required this.onTaskTap,
    required this.onTaskDrop,
  });

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
                  child: QuadrantCard(
                    quadrantKey: TaskConstants.quadrantDoFirst,
                    emoji: '🔴',
                    title: 'Khẩn cấp và Quan trọng',
                    color: TaskConstants.colorDoFirst,
                    tasks: tasksByQuadrant[TaskConstants.quadrantDoFirst] ?? [],
                    onTaskTap: onTaskTap,
                    onTaskDrop: onTaskDrop,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: QuadrantCard(
                    quadrantKey: TaskConstants.quadrantSchedule,
                    emoji: '🟡',
                    title: 'Không gấp mà quan trọng',
                    color: TaskConstants.colorSchedule,
                    tasks:
                        tasksByQuadrant[TaskConstants.quadrantSchedule] ?? [],
                    onTaskTap: onTaskTap,
                    onTaskDrop: onTaskDrop,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Hàng dưới: III & IV
            Row(
              children: [
                Expanded(
                  child: QuadrantCard(
                    quadrantKey: TaskConstants.quadrantDelegate,
                    emoji: '🔵',
                    title: 'Khẩn cấp nhưng không quan trọng',
                    color: TaskConstants.colorDelegate,
                    tasks:
                        tasksByQuadrant[TaskConstants.quadrantDelegate] ?? [],
                    onTaskTap: onTaskTap,
                    onTaskDrop: onTaskDrop,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: QuadrantCard(
                    quadrantKey: TaskConstants.quadrantEliminate,
                    emoji: '🟢',
                    title: 'Không cấp bách và không quan trọng',
                    color: TaskConstants.colorEliminate,
                    tasks:
                        tasksByQuadrant[TaskConstants.quadrantEliminate] ?? [],
                    onTaskTap: onTaskTap,
                    onTaskDrop: onTaskDrop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
