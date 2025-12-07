import 'package:flutter/material.dart';

class AddReminderDialog extends StatelessWidget {
  final Function(String) onReminderSelected;

  const AddReminderDialog({super.key, required this.onReminderSelected});

  static const List<String> _options = [
    'Cả ngày',
    '5 phút trước',
    '10 phút trước',
    '15 phút trước',
    '30 phút trước',
    '1 giờ trước',
    '1 ngày trước',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                const Text(
                  'Thời gian nhắc nhở ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: _options.map((option) {
                return ListTile(
                  title: Text(
                    option,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    onReminderSelected(option);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
