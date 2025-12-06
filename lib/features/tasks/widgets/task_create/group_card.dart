import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.selectedGroup,
    required this.onGroupChanged,
    required this.groups,
  });

  final String selectedGroup;
  final ValueChanged<String> onGroupChanged;
  final List<String> groups;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showGroupPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            // Text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Group",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedGroup,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(Icons.expand_more,
                color: Colors.grey.shade500, size: 26),

            const SizedBox(width: 12),

            // Add button
            InkWell(
              onTap: () {
                // xử lý thêm nhóm
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6BA8),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet picker
  void _showGroupPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Chọn nhóm",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...groups.map((group) {
              final bool isSelected = group == selectedGroup;

              return ListTile(
                title: Text(
                  group,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? const Color(0xFF7C6BA8) : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Color(0xFF7C6BA8))
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onGroupChanged(group);
                },
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
