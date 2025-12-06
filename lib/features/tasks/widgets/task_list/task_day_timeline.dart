import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flip/features/tasks/models/task_item.dart';
import 'package:flip/features/tasks/widgets/task_list/task_detail_modal.dart';

class TaskDayTimeline extends StatelessWidget {
  final DateTime day;
  final List<TaskItem> tasks;

  const TaskDayTimeline({super.key, required this.day, required this.tasks});

  @override
  Widget build(BuildContext context) {
    // group task theo từng giờ (0-23)
    final Map<int, List<TaskItem>> tasksByHour = {
      for (var h = 0; h < 24; h++) h: [],
    };
    for (final t in tasks) {
      final startHour = t.startTime.hour;
      tasksByHour[startHour]?.add(t);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: 24,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Colors.grey, thickness: 0.2),
      itemBuilder: (context, index) {
        final hour = index;
        final hourTasks = tasksByHour[hour] ?? [];
        final labelTime = TimeOfDay(hour: hour, minute: 0);
        final timeText = labelTime.format(context);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Text(
                timeText,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: hourTasks.isEmpty
                  ? const SizedBox(height: 36)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: hourTasks
                          .map(
                            (t) => GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => TaskDetailModal(task: t),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: t.color.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: t.color.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: t.color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${DateFormat.Hm().format(t.startTime)} - ${DateFormat.Hm().format(t.endTime)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          if (t.subtitle.isNotEmpty)
                                            Text(
                                              t.subtitle,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}
