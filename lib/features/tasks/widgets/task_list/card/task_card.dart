import 'dart:async';
import 'package:flip/features/tasks/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late int _currentPercent;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentPercent = widget.task.getAutoPercent();
    _startPercentTimer();
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _currentPercent = widget.task.getAutoPercent();
    }
  }

  void _startPercentTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newPercent = widget.task.getAutoPercent();
      if (newPercent != _currentPercent) {
        setState(() {
          _currentPercent = newPercent;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const radius = 24.0;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: widget.task.color.withOpacity(0.85),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt,
                color: AppColors.xanh3,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Nội dung chính
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.task.subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_currentPercent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.task.durationText,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),

            const SizedBox(width: 8),
            const Icon(Icons.more_vert, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
