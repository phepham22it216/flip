import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/features/tasks/models/task_model.dart';

class StatisticsCard extends StatelessWidget {
  final List<TaskModel> tasks;
  final int overdueCount;

  const StatisticsCard({
    super.key,
    required this.tasks,
    required this.overdueCount,
  });

  @override
  Widget build(BuildContext context) {
    final totalIncomplete = tasks.where((t) => !t.isDone).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.xanh1, AppColors.xanh3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.xanh1.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pending_actions,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalIncomplete Công việc',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (overdueCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.doSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$overdueCount Quá hạn',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
