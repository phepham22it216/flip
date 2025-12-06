import 'package:flutter/material.dart';
import 'package:flip/features/tasks/models/task_item.dart';
import 'package:flip/features/tasks/widgets/task_list/task_detail_modal.dart';

class WeekTimeTable extends StatelessWidget {
  final DateTime weekStart;
  final List<TaskItem> tasks;
  final List<int> hours;

  const WeekTimeTable({
    Key? key,
    required this.weekStart,
    required this.tasks,
    this.hours = const [
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
    ],
  }) : super(key: key);

  String _weekdayLabel(int weekday) {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return labels[(weekday - 1) % 7];
  }

  String _dayString(DateTime d) => d.day.toString();

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 48.0 + 7 * 80.0, // 48 cho giờ, 80 cho mỗi ngày
        child: Column(
          children: [
            // Header: days of week
            Row(
              children: [
                const SizedBox(width: 48, height: 40),
                ...days.map(
                  (d) => SizedBox(
                    width: 80,
                    height: 40,
                    child: Center(
                      child: Text(
                        _weekdayLabel(d.weekday) + '\n' + _dayString(d),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: hours.length,
                itemBuilder: (context, i) {
                  final hour = hours[i];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 60,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            hour.toString().padLeft(2, '0') + ':00',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      ...days.map((d) {
                        final cellTasks = tasks
                            .where(
                              (t) =>
                                  t.startTime.year == d.year &&
                                  t.startTime.month == d.month &&
                                  t.startTime.day == d.day &&
                                  t.startTime.hour == hour,
                            )
                            .toList();
                        return SizedBox(
                          width: 80,
                          height: 60,
                          child: Container(
                            margin: const EdgeInsets.all(1),
                            color: Colors.white,
                            child: Stack(
                              children: [
                                for (final task in cellTasks)
                                  Positioned.fill(
                                    child: GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (ctx) =>
                                              TaskDetailModal(task: task),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            task.title,
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
