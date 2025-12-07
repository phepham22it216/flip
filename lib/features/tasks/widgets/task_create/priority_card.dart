import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'task_section_card.dart';

class PriorityCard extends StatelessWidget {
  const PriorityCard({
    required this.selectedPriority,
    required this.onPriorityChanged,
    super.key,
  });

  final int selectedPriority;
  final ValueChanged<int> onPriorityChanged;

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Trung bình';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TaskSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.priority_high, color: AppColors.xanh1),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Mức độ quan trọng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (index) {
              final priority = index + 1;
              final isSelected = priority == selectedPriority;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onPriorityChanged(priority),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getPriorityColor(priority)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: _getPriorityColor(priority),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Text(
                      _getPriorityLabel(priority),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
