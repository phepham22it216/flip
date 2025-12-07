import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flip/theme/app_colors.dart';

enum _TaskMenuAction { complete, edit, delete }

class TaskDetailModal extends StatefulWidget {
  final TaskModel task;

  const TaskDetailModal({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailModal> createState() => _TaskDetailModalState();
}

class _TaskDetailModalState extends State<TaskDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final date = DateFormat('EEE, dd MMM yyyy', 'vi_VN').format(dt);
    final time = DateFormat('HH:mm').format(dt);
    return '$date · $time';
  }

  void _onMenuSelected(BuildContext context, _TaskMenuAction action) {
    // TODO: hook up real handlers for: complete, edit, delete
    final label = switch (action) {
      _TaskMenuAction.complete => 'Hoàn thành nhiệm vụ này',
      _TaskMenuAction.edit => 'Chỉnh sửa',
      _TaskMenuAction.delete => 'Xóa',
    };

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
  }

  void _showPopoverMenu(BuildContext buttonContext) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(buttonContext).context.findRenderObject() as RenderBox;
    final buttonRect =
        button.localToGlobal(Offset.zero, ancestor: overlay) & button.size;

    final position = RelativeRect.fromLTRB(
      buttonRect.left,
      buttonRect.bottom + 4,
      overlay.size.width - buttonRect.left - buttonRect.width,
      overlay.size.height - buttonRect.bottom,
    );

    showMenu<_TaskMenuAction>(
      context: buttonContext,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      constraints: const BoxConstraints(minWidth: 0),
      items: [
        const PopupMenuItem(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          value: _TaskMenuAction.complete,
          child: Text('Hoàn thành nhiệm vụ'),
        ),
        const PopupMenuItem(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(height: 1, thickness: 1, color: Color(0xFFD0C4B5)),
        ),
        const PopupMenuItem(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          value: _TaskMenuAction.edit,
          child: Text('Chỉnh sửa'),
        ),
        const PopupMenuItem(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(height: 1, thickness: 1, color: Color(0xFFD0C4B5)),
        ),
        const PopupMenuItem(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          value: _TaskMenuAction.delete,
          child: Text('Xóa', style: TextStyle(color: Colors.red)),
        ),
      ],
    ).then((value) {
      if (value != null) _onMenuSelected(buttonContext, value);
    });
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
    final start = _formatDateTime(widget.task.startTime);
    final end = _formatDateTime(widget.task.endTime);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.task.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Builder(
                            builder: (btnCtx) => IconButton(
                              tooltip: 'Tùy chọn',
                              icon: const Icon(
                                Icons.more_horiz,
                                color: AppColors.xanhLa1,
                              ),
                              onPressed: () => _showPopoverMenu(btnCtx),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Thời gian
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
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
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.xanhLa2,
                            ),
                            const SizedBox(width: 12),
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
                                      fontSize: 13,
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

                      const SizedBox(height: 16),

                      // Mức độ quan trọng
                      _ModalDetailTile(
                        icon: Icons.flag_rounded,
                        iconColor: _priorityColor(widget.task.priority),
                        title: 'Mức độ quan trọng',
                        value: _priorityText(widget.task.priority),
                      ),

                      // Độ khó
                      _ModalDetailTile(
                        icon: Icons.flash_on_rounded,
                        iconColor: _difficultyColor(widget.task.difficulty),
                        title: 'Độ khó',
                        value: _difficultyText(widget.task.difficulty),
                      ),

                      // Nhóm
                      _ModalDetailTile(
                        icon: Icons.group_rounded,
                        iconColor: AppColors.xanh1,
                        title: 'Nhóm',
                        value: widget.task.groupName.isNotEmpty
                            ? widget.task.groupName
                            : 'Chưa xác định',
                      ),

                      // Trạng thái
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    (widget.task.isDone
                                            ? AppColors.xanhLa2
                                            : AppColors.doSoft)
                                        .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 18,
                                color: widget.task.isDone
                                    ? AppColors.xanhLa2
                                    : AppColors.doSoft,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: const Text(
                                'Trạng thái',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              widget.task.isDone
                                  ? 'Đã hoàn thành'
                                  : 'Chưa xong',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: widget.task.isDone
                                    ? AppColors.xanhLa2
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Chi tiết mô tả
                      if (widget.task.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Chi tiết',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.task.subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalDetailTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _ModalDetailTile({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
