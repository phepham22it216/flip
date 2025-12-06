import 'package:flutter/material.dart';

class TitleCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController noteController;
  final VoidCallback onAddSticker;

  const TitleCard({
    super.key,
    required this.titleController,
    required this.noteController,
    required this.onAddSticker,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: 'Tiêu đề',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: noteController,
          decoration: InputDecoration(
            hintText: 'Ghi chú',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );
  }
}
