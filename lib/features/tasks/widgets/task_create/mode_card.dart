import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';
import 'task_section_card.dart';

class ModeCard extends StatelessWidget {
  const ModeCard({
    required this.isGroupMode,
    required this.onModeChanged,
    super.key,
  });

  final bool isGroupMode;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return TaskSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group, color: AppColors.xanh1),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Loại',
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
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onModeChanged(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !isGroupMode
                          ? AppColors.xanh1
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: !isGroupMode
                          ? Border.all(color: AppColors.xanh1, width: 2)
                          : null,
                    ),
                    child: Text(
                      'Cá nhân',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: !isGroupMode
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => onModeChanged(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isGroupMode
                          ? AppColors.xanh2
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: isGroupMode
                          ? Border.all(color: AppColors.xanh2, width: 2)
                          : null,
                    ),
                    child: Text(
                      'Nhóm',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isGroupMode
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
