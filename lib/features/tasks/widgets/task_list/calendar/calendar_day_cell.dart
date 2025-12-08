import 'package:flutter/material.dart';

import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/screens/task_detail_page.dart';
import 'package:flip/theme/app_colors.dart';

class CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;
  final List<TaskModel> tasks;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isOutside,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isOutside ? Colors.grey.shade400 : Colors.black87;
    final bgColor = isSelected
        ? AppColors.xanh1.withOpacity(0.08)
        : isToday
        ? AppColors.xanh1.withOpacity(0.04)
        : Colors.white;

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: AppColors.vang.withOpacity(0.7),
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isOutside
                            ? FontWeight.w600
                            : FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.xanh1,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 2),
            if (tasks.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length > 2 ? 2 : tasks.length,
                  itemBuilder: (context, index) {
                    return _TaskPill(task: tasks[index], isOutside: isOutside);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskPill extends StatelessWidget {
  final TaskModel task;
  final bool isOutside;

  const _TaskPill({required this.task, required this.isOutside});

  @override
  Widget build(BuildContext context) {
    final textColor = isOutside ? Colors.grey.shade500 : Colors.white;
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => TaskDetailModal(task: task),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: task.color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
