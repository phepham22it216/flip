import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

import 'task_section_card.dart';

class TitleCard extends StatelessWidget {
  const TitleCard({
    required this.titleController,
    required this.noteController,
    required this.onAddSticker,
    super.key,
  });

  final TextEditingController titleController;
  final TextEditingController noteController;
  final VoidCallback onAddSticker;

  @override
  Widget build(BuildContext context) {
    return TaskSectionCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tiêu đề',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Thêm chi tiết',
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onAddSticker,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            icon: const Icon(Icons.add, color: AppColors.xanh1),
            label: const Text(
              'Sticker',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
