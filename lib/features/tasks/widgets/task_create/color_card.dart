import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

import 'task_section_card.dart';

class TaskColorOption {
  const TaskColorOption({required this.label, required this.color});

  final String label;
  final Color color;
}

class ColorCard extends StatelessWidget {
  const ColorCard({
    required this.colorOptions,
    required this.selectedIndex,
    required this.onSelect,
    required this.onCustomColor,
    super.key,
  });

  final List<TaskColorOption> colorOptions;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCustomColor;

  @override
  Widget build(BuildContext context) {
    final selected = colorOptions[selectedIndex];
    return TaskSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, color: AppColors.xanh1),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Màu ${selected.label.toLowerCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              // Đã xóa icon chevron_right
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colorOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onSelect(index),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: option.color,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: option.color.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
