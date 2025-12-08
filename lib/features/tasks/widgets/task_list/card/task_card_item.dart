import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flip/features/tasks/models/task_model.dart';

class TaskCardItem extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onMenu;

  const TaskCardItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onMenu,
  });

  @override
  State<TaskCardItem> createState() => _TaskCardItemState();
}

class _TaskCardItemState extends State<TaskCardItem> {
  late int _currentPercent;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentPercent = widget.task.getAutoPercent();
    _startPercentTimer();
  }

  @override
  void didUpdateWidget(covariant TaskCardItem oldWidget) {
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
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: widget.task.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Nút tick
              IconButton(
                iconSize: 28,
                padding: EdgeInsets.zero,
                icon: Icon(
                  widget.task.isDone
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: Colors.white,
                ),
                onPressed: widget.onToggle,
              ),

              const SizedBox(width: 12),

              // Title + repeat text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.task.groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // % + time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_currentPercent%',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.task.durationText,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Menu button
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: widget.onMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
