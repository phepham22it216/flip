import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flip/features/tasks/models/task_item.dart';
import 'package:flip/theme/app_colors.dart';

class TaskDetailPage extends StatelessWidget {
  final TaskItem task;

  const TaskDetailPage({Key? key, required this.task}) : super(key: key);

  String _formatDateTime(DateTime dt) {
    final date = DateFormat('EEE, dd MMM yyyy', 'vi_VN').format(dt);
    final time = DateFormat('HH:mm').format(dt);
    return '$date  ·  $time';
  }

  String _priorityText(int p) {
    switch (p) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }

  Color _priorityColor(int p) {
    switch (p) {
      case 1:
        return AppColors.xanh2;
      case 2:
        return AppColors.vang;
      case 3:
        return AppColors.doSoft;
      default:
        return Colors.grey;
    }
  }

  String _difficultyText(int d) {
    switch (d) {
      case 1:
        return 'Dễ';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Khó';
      default:
        return 'Không xác định';
    }
  }

  Color _difficultyColor(int d) {
    switch (d) {
      case 1:
        return AppColors.xanhLa1;
      case 2:
        return AppColors.vang;
      case 3:
        return AppColors.doSoft;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = _formatDateTime(task.startTime);
    final end = _formatDateTime(task.endTime);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card thời gian
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    color: Colors.black.withOpacity(0.08),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bắt đầu',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          start,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.xanhLa2,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Kết thúc',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          end,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mức độ quan trọng
            _DetailTile(
              icon: Icons.flag_rounded,
              iconColor: _priorityColor(task.priority),
              title: 'Mức độ quan trọng',
              value: _priorityText(task.priority),
            ),

            // Độ khó
            _DetailTile(
              icon: Icons.flash_on_rounded,
              iconColor: _difficultyColor(task.difficulty),
              title: 'Độ khó',
              value: _difficultyText(task.difficulty),
            ),

            // Nhóm
            _DetailTile(
              icon: Icons.group_rounded,
              iconColor: AppColors.xanh1,
              title: 'Nhóm',
              value: task.groupName.isNotEmpty
                  ? task.groupName
                  : 'Chưa xác định',
            ),

            // Trạng thái cá nhân
            _DetailTile(
              icon: Icons.person_rounded,
              iconColor: task.isDone ? AppColors.xanhLa2 : AppColors.doSoft,
              title: 'Trạng thái cá nhân',
              valueWidget: Row(
                children: [
                  Icon(
                    task.isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: task.isDone ? AppColors.xanhLa2 : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.isDone ? 'Đã hoàn thành' : 'Chưa hoàn thành',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: task.isDone ? AppColors.xanhLa2 : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Chi tiết / Mô tả
            if (task.subtitle.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Chi tiết',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                child: Text(
                  task.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? value;
  final Widget? valueWidget;

  const _DetailTile({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.value,
    this.valueWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          valueWidget ??
              Text(
                value ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
        ],
      ),
    );
  }
}
