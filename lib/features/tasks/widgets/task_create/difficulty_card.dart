import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'task_section_card.dart';

class DifficultyCard extends StatelessWidget {
  const DifficultyCard({
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
    super.key,
  });

  final int selectedDifficulty;
  final ValueChanged<int> onDifficultyChanged;

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Dễ';
      case 2:
        return 'Vừa';
      case 3:
        return 'Khó';
      default:
        return 'Vừa';
    }
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.lightBlue;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.deepOrange;
      default:
        return Colors.purple;
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
              const Icon(Icons.trending_up, color: AppColors.xanh1),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Độ khó dễ',
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
              final difficulty = index + 1;
              final isSelected = difficulty == selectedDifficulty;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onDifficultyChanged(difficulty),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getDifficultyColor(difficulty)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: _getDifficultyColor(difficulty),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Text(
                      _getDifficultyLabel(difficulty),
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
