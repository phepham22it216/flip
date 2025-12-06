import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/features/tasks/widgets/task_incomplete/filter_tabs.dart';

class EmptyState extends StatelessWidget {
  final TaskFilter selectedFilter;

  const EmptyState({super.key, required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;

    switch (selectedFilter) {
      case TaskFilter.today:
        message = 'Không có công việc nào hôm nay';
        icon = Icons.today;
        break;
      case TaskFilter.overdue:
        message = 'Không có công việc quá hạn';
        icon = Icons.celebration;
        break;
      case TaskFilter.upcoming:
        message = 'Không có công việc sắp tới';
        icon = Icons.event_available;
        break;
      case TaskFilter.all:
      default:
        message = 'Tuyệt vời! Bạn đã hoàn thành tất cả';
        icon = Icons.task_alt;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.xanh1.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: AppColors.xanh1),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
