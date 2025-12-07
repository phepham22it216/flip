import 'package:flutter/material.dart';

class TaskColorOption {
  final String label;
  final Color color;

  const TaskColorOption({required this.label, required this.color});
}

class ColorCard extends StatelessWidget {
  final List<TaskColorOption> colorOptions;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCustomColor;

  const ColorCard({
    super.key,
    required this.colorOptions,
    required this.selectedIndex,
    required this.onSelect,
    required this.onCustomColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Màu sắc',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                colorOptions.length,
                (index) => GestureDetector(
                  onTap: () => onSelect(index),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colorOptions[index].color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedIndex == index
                            ? Colors.black
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: selectedIndex == index
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onCustomColor,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
