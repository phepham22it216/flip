import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/features/tasks/screens/task_detail_page.dart';
import 'package:intl/intl.dart';

class IncompleteTaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isOverdue;

  const IncompleteTaskCard({
    super.key,
    required this.task,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => TaskDetailModal(task: task),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue
                ? AppColors.doSoft.withOpacity(0.3)
                : task.color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Color indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: task.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForGroup(task.groupName),
                    color: task.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (task.pinned)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.push_pin,
                                size: 16,
                                color: AppColors.cam,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              task.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.groupName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Priority badge
                _buildPriorityBadge(task.priority),
              ],
            ),
            if (task.subtitle.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                task.subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                // Time
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('HH:mm').format(task.startTime)} - ${DateFormat('HH:mm').format(task.endTime)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const Spacer(),
                // Progress
                _buildProgressIndicator(task.getAutoPercent(), task.color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(int priority) {
    String label;
    Color color;

    switch (priority) {
      case 3:
        label = 'Cao';
        color = AppColors.doSoft;
        break;
      case 2:
        label = 'TB';
        color = AppColors.cam;
        break;
      case 1:
      default:
        label = 'Thấp';
        color = AppColors.xanhLa1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int percent, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getIconForGroup(String groupName) {
    switch (groupName.toLowerCase()) {
      case 'học tập':
        return Icons.school;
      case 'lớp học':
        return Icons.class_;
      case 'lập trình':
        return Icons.code;
      case 'project':
        return Icons.folder_special;
      case 'team':
        return Icons.groups;
      default:
        return Icons.task;
    }
  }
}
