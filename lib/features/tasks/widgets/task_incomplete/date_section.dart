import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/features/tasks/models/task_item.dart';
import 'package:flip/features/tasks/widgets/task_incomplete/incomplete_task_card.dart';
import 'package:intl/intl.dart';

class DateSection extends StatelessWidget {
  final DateTime date;
  final List<TaskItem> tasks;

  const DateSection({super.key, required this.date, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue = date.isBefore(today);
    final isToday = date.isAtSameMomentAs(today);

    String dateLabel;
    Color dateColor;

    if (isToday) {
      dateLabel = 'Hôm nay';
      dateColor = AppColors.xanh1;
    } else if (isOverdue) {
      dateLabel = 'Quá hạn - ${DateFormat('dd/MM/yyyy').format(date)}';
      dateColor = AppColors.doSoft;
    } else {
      dateLabel = DateFormat('EEEE, dd/MM/yyyy', 'vi').format(date);
      dateColor = AppColors.textPrimary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: dateColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateLabel,
                style: TextStyle(
                  color: dateColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: dateColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: TextStyle(
                    color: dateColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...tasks.map(
          (task) => IncompleteTaskCard(task: task, isOverdue: isOverdue),
        ),
      ],
    );
  }
}
