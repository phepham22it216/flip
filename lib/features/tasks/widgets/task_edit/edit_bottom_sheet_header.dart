import 'package:flutter/material.dart';

class EditBottomSheetHeader extends StatelessWidget {
  final TextEditingController titleController;
  final VoidCallback onBackPressed;
  final VoidCallback onCheckPressed;

  const EditBottomSheetHeader({
    super.key,
    required this.titleController,
    required this.onBackPressed,
    required this.onCheckPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Header with back arrow, title, and checkmark
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 24),
                onPressed: onBackPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: TextField(
                  controller: titleController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tiêu đề',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check, size: 24, color: Colors.green),
                onPressed: onCheckPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
