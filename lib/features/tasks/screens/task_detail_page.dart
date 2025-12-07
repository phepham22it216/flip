import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/theme/app_colors.dart';
import 'package:flip/features/tasks/widgets/task_detail/detail_tile.dart';
import 'package:flip/features/tasks/widgets/task_detail/time_range_card.dart';
import 'package:flip/features/tasks/widgets/task_detail/task_helpers.dart';

enum _TaskMenuAction { complete, edit, delete }

class TaskDetailPage extends StatefulWidget {
  final TaskModel task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  String _formatDateTime(DateTime dt) {
    final date = DateFormat('EEE, dd MMM yyyy', 'vi_VN').format(dt);
    final time = DateFormat('HH:mm').format(dt);
    return '$date  ·  $time';
  }

  void _onMenuSelected(BuildContext context, _TaskMenuAction action) {
    final label = switch (action) {
      _TaskMenuAction.complete => 'Hoàn thành nhiệm vụ này',
      _TaskMenuAction.edit => 'Chỉnh sửa',
      _TaskMenuAction.delete => 'Xóa',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionRow(
                label: 'Hoàn thành nhiệm vụ này',
                onTap: () {
                  Navigator.pop(ctx);
                  _onMenuSelected(context, _TaskMenuAction.complete);
                },
              ),
              const Divider(height: 1),
              _ActionRow(
                label: 'Chỉnh sửa',
                onTap: () {
                  Navigator.pop(ctx);
                  _onMenuSelected(context, _TaskMenuAction.edit);
                },
              ),
              const Divider(height: 1),
              _ActionRow(
                label: 'Xóa',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  _onMenuSelected(context, _TaskMenuAction.delete);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = _formatDateTime(widget.task.startTime);
    final end = _formatDateTime(widget.task.endTime);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 110,
        title: Text(
          widget.task.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              tooltip: 'Tùy chọn',
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.xanhLa1,
              ),
              onPressed: () => _showActionSheet(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card thời gian
            TimeRangeCard(startTime: start, endTime: end),

            const SizedBox(height: 24),

            // Mức độ quan trọng
            DetailTile(
              icon: Icons.flag_rounded,
              iconColor: TaskHelpers.priorityColor(widget.task.priority),
              title: 'Mức độ quan trọng',
              value: TaskHelpers.priorityText(widget.task.priority),
            ),

            // Độ khó
            DetailTile(
              icon: Icons.flash_on_rounded,
              iconColor: TaskHelpers.difficultyColor(widget.task.difficulty),
              title: 'Độ khó',
              value: TaskHelpers.difficultyText(widget.task.difficulty),
            ),

            // Nhóm
            DetailTile(
              icon: Icons.group_rounded,
              iconColor: AppColors.xanh1,
              title: 'Nhóm',
              value: widget.task.groupName.isNotEmpty
                  ? widget.task.groupName
                  : 'Chưa xác định',
            ),

            // Trạng thái
            DetailTile(
              icon: Icons.person_rounded,
              iconColor: widget.task.isDone
                  ? AppColors.xanhLa2
                  : AppColors.doSoft,
              title: 'Trạng thái',
              valueWidget: Text(
                widget.task.isDone ? 'Đã hoàn thành' : 'Chưa xong',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.task.isDone
                      ? AppColors.xanhLa2
                      : Colors.grey[700],
                ),
              ),
            ),

            // Chi tiết / Mô tả
            if (widget.task.subtitle.isNotEmpty) ...[
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
                  widget.task.subtitle,
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

class _ActionRow extends StatelessWidget {
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionRow({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
